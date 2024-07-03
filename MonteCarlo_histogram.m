%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run Monte Carlo sims of classrooms with random IC
%% Create histogram of resultant data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MonteCarlo_histogram()


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

    %number of simulations per parameter choices
    num_sims = 10;

    %%%%%%%%%%%%%%%%%%%%
    %% Parameters 
    %%%%%%%%%%%%%%%%%%%%

    %Receptiveness parameter
    gam = .95;

    %Number of students in classroom
    S = 30;

    %Threshold parameter
    epsilon = 0.1;

    %convergence check
    convErr = .0001; %If change is less than this, then converged
    
    %Time vector
    tVec = 1:1:10000;
    endTime = tVec(end);


    %Keep track of starting and ending anxieties for all students
    start_anxiety = zeros(S,num_sims);
    end_anxiety = start_anxiety;



    %%%%%%%%%%%%%%%%%%%
    %% Group structure
    %%%%%%%%%%%%%%%%%%%

    %Students per group
    studs = 4;

    %number of groups
    m = floor(S/studs);

    %switch groups?
    switch_groups = false; %set true to switch groups periodically
    whenToSwitchGroups = 70; %how many timesteps before switching groups

      
    %Monte Carlo
        parfor j = 1:num_sims %many simulations of random classrooms

            %%%%%%%%%%%%%%%%%
            %% Initialization
            %%%%%%%%%%%%%%%%%
            %Initial anxiety levels
            xVec=rand(S,1); %current anxiety status at timestep - column vector NOT 
                             %row vector - sets anxiety levels to random number 
                             %between [0,1] - for (n,1) n is how many total people in
                             %classroom 
            %xVec = sort(xVec);
            start_anxiety(:,j) = xVec;
            changeInTimeStep = 1; %calculate total change in each time step
                        %L1 change

            %Adjacency matrix for group interactions
        
                %If forming groups randomly:
                    A = groups_matrix(S,m); %randomly formed groups of size m in class of S students
                
                %If forming groups homogeneously:
                    %xVec = sort(xVec);
                    %A = groups_matrix_ordered(S,m); %groups formed homogeneously by anxiety
           
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

            end_anxiety(:,j) = xVec;
            disp(j)
        end

        start_anxiety = reshape(start_anxiety,[],1);
        end_anxiety = reshape(end_anxiety,[],1);

        percent_change = (end_anxiety-start_anxiety);
        percentage_improved = sum((percent_change<-0.0000001)*1)/length(percent_change);
        disp('Percentage Improved:')
        disp(percentage_improved)

       
        average_end = mean(end_anxiety);
        disp('Average ending anxiety:')
        disp(average_end)


        figure(1)
         histogram(percent_change,'Normalization','pdf')
         title('Change in anxiety','interpreter','latex')
         a=gca;
         a.FontSize=16;
         saveas(gcf,'histogram_change_in_anxiety.fig')


        figure(2)
         histogram(end_anxiety,'Normalization','pdf')
         title('Final anxiety','interpreter','latex')
         a=gca;
         a.FontSize=16;
         saveas(gcf,'histogram_average_end_anxiety.fig')
        % drawnow



end