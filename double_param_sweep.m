%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run Monte Carlo sims of classrooms with random IC
%% Sweep over parameters gamma and epsilon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function double_param_sweep()


% sz = getenv('SLURM_NTASKS');
% if isempty(sz)
%     % For some reason, we're not running in a Slurm job
%     sz = maxNumCompThreads;
% end
% 
% sz = str2num(sz);
% % Time how long it takes to start the pool
% tic
% parpool(sz);
% toc

close('all')

    %number of Monte Carlo samples 
    num_sims = 10;

    %%%%%%%%%%%%%%%%%%%%
    %% Parameters and initialization 
    %%%%%%%%%%%%%%%%%%%%

    %Number of students in classroom
    S = 30;

    %convergence check
    convErr = .0001; %If change is less than this, then converged
    
    %Time vector
    tVec = 1:1:10000;
    endTime = tVec(end);
    
    %%%%%%%%%%%%%%%%%%%
    %% Group structure
    %%%%%%%%%%%%%%%%%%%

    %Students per group
    studs = S;

    %number of groups
    num_groups = floor(S/studs);
    
    %switch groups?
    switch_groups = false; %set true to switch groups periodically
    whenToSwitchGroups = 100; %how many timesteps before switching groups

    %%%%%%%%%%%%
    %% Parameters to sweep
    %%%%%%%%%%%%

        gamVec = linspace(0.01,0.9999,10);
        epsVec = linspace(0.01,0.4,5);

    %Sweep over parameters
    for k = 1:length(gamVec)
        for m = 1:length(epsVec)
       
             gam = gamVec(k);
             epsilon = epsVec(m);
                 
            %Keep track of starting and ending anxieties for all students
            start_anxiety = [];
            end_anxiety = [];
            
            %Monte Carlo
                for j = 1:num_sims %many simulations of random classrooms
        
                    %%%%%%%%%%%%%%%%%
                    %% Initialization
                    %%%%%%%%%%%%%%%%%
                    %Initial anxiety levels
                    xVec=rand(S,1); %current anxiety status at timestep - column vector NOT 
                                     %row vector - sets anxiety levels to random number 
                                     %between [0,1] - for (n,1) n is how many total people in
                                     %classroom 
                    start_anxiety = [start_anxiety; xVec];
                    changeInTimeStep = 1; %calculate total change in each time step
                                %L1 change
        
        
                    %Adjacency matrix of interactions
                    A=groups_matrix(S,num_groups); %calling matrix from function standardmatrix with n-1 students    
                    
                    i = 1;
        
                
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% Timestep anxiety levels
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    while changeInTimeStep>convErr && i < endTime
                        i = i+1;
                        [xVec,changeInTimeStep] = BC_model_steps(A,xVec,epsilon,gam); %Update one time step
                        if switch_groups 
                             changeInTimeStep = 1; %do not end early for equilibria
                             if mod(i,whenToSwitchGroups)==0 %make new groups
                                   A=groups_matrix(S,num_groups);
                             end
                        end
                    end
        
                    end_anxiety = [end_anxiety;xVec];
                end

                %For these parameter values, calculate 
                %statistics of interest
                percent_change = (end_anxiety-start_anxiety);
                percentage_improved(m,k) = sum((percent_change<-0.0000001)*1)/length(percent_change);

                average_end(m,k) = mean(end_anxiety);

        end
        disp(k/length(gamVec)) %percentdone 
    end

    %%%%%%%%%%%%%%%
    %% Plot results
    %%%%%%%%%%%%%%%

    [X,Y] = meshgrid(epsVec,gamVec);

    figure(1)
    surf(X,Y,percentage_improved')
    xlabel('$\varepsilon$','interpreter','latex')
    ylabel('$\gamma$','interpreter','latex')
    zlabel('$P(x^{T_{final}})$','interpreter','latex')
    a=gca;
    a.FontSize = 16;

    figure(2)
    surf(X,Y,average_end')
    xlabel('$\varepsilon$','interpreter','latex')
    ylabel('$\gamma$','interpreter','latex')
    zlabel('$\langle x^{T_{final}}\rangle$','interpreter','latex')
    a=gca;
    a.FontSize = 16;

end
    

   