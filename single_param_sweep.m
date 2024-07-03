%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run Monte Carlo sims of classrooms with random IC
%% Sweep over any parameter of choice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function single_param_sweep()

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

clf
clear 

    %number of simulations per parameter choices
    num_sims = 1000;

    %%%%%%%%%%%%%%%%%%%%
    %% Parameters
    %%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%
    %%SWEEPING VECTOR
    %%%%%%%%%%%%%%%%
    
    sweepVec = linspace(0,100,101); %parameter to sweep
    %Must also change corresponding parameter on line 68
    
    %receptiveness parameter
    gam = .95;

    %Num students
    S = 30;

    %Threshold
    epsilon = 0.1;

    %Students per group
    studs = 3;

    %number of groups
    m = floor(S/studs);

    %convergence check
    convErr = .0001; %If change is less than this, then converged
    
    %Time vector
    tVec = 1:1:10000; %each timestep is a day of interaction?
    endTime = tVec(end);

    
    %switch groups?
    switch_groups = true; %set true to switch groups periodically
    whenToSwitchGroups = 100; %how many timesteps before switching groups


    %Sweep over parameter
    for k = 1:length(sweepVec)
        
        whenToSwitchGroups = sweepVec(k); %parameter to sweep

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
            A=groups_matrix(S,m); %calling matrix from function standardmatrix with n-1 students    
            
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
                    A=groups_matrix(S,m);
                end
        end
            end

            end_anxiety = [end_anxiety;xVec];
        end

        endingData(:,k) = end_anxiety;

        percent_change(:,k) = (end_anxiety-start_anxiety);
        percentage_improved(k) = sum((percent_change(:,k)<-0.00001)*1)/length(percent_change(:,k));
        %percentage_worse(k) = 1-percentage_improved;
       
        average_start(k) = mean(start_anxiety);
        average_end(k) = mean(end_anxiety);
        disp(k)

    end


        figure(3)
   
        plot(sweepVec,percentage_improved,'.','MarkerSize',10)
        hold on
        plot(sweepVec, average_end,'.','MarkerSize',10)
        legend('Percentage improved','Average end')
        a=gca;
        a.FontSize =16;
        saveas(gcf,'group_size_sweep_switch_groups_size3.fig')

        figure(4)
        make3DHistogram(endingData,sweepVec)
        saveas(gcf,'histogram3d_switch_groups_size3.fig')

    end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make Histogram 3D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function make3DHistogram(data,sweepVec)
    %input: data - M by N data matrix, M data points along N values of
    %parameter
    %       sweepVec - N by 1 vector of values of parameter

    num_bins = 100;
    zSurf = zeros(num_bins,length(sweepVec)); %eventual histogram values, in matrix
    for j  = 1:length(sweepVec)
        curHistogram = histogram(data(:,j),num_bins,'BinEdges',linspace(0,1,num_bins+1),'Normalization','pdf');
        zSurf(:,j) = curHistogram.Values;
    end
    [X,Y] = meshgrid(linspace(0,1,num_bins),sweepVec);
    surf(X,Y,zSurf')
    xlabel('Ending anxiety')
    ylabel('Parameter')
end