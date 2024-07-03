%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single simulation of math anxiety BC model
%
%
%  Dynamics: x_i^{t+1} = 1/(1+|I_i|)*(x_i+\sum A_{ij}^t f(x_i^t,x_j^t))
%
%             f(x,y)=  gam x if x anxiety goes down |x-y|<epsilon
%             f(x,y) = (1-gam)+gam x if x anxiety goes up x>y+epsilon
%
%             gam - sensitivity/receptiveness parameter
%             epsilon - threshold for good/bad interactions
%             A_{ij} - adjacency matrix; group structure at time t
%             I_i - number of students influencing student i.
%
%  Output: pixel plot of classroom group structure 
%          time series of anxiety levels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function anxiety_model_time_series()

clf
figure(1)

    %%%%%%%%%%%%%%%%%%%%
    %% Parameters and initialization 
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
    
    %Current timestep
    i = 1;

    changeInTimeStep = 1; %calculate total change in each time step
                        %L1 change

    %Initial anxiety levels
    xVec=rand(S,1); %current anxiety status at timestep - column vector NOT 
                     %row vector - sets anxiety levels to random number 
                     %between [0,1] - for (n,1) n is how many total people in
                     %classroom 


    %%%%%%%%%%%%%%%%%%%
    %% Group structure
    %%%%%%%%%%%%%%%%%%%

    %Students per group
    studs = 4;

    %number of groups
    m = floor(S/studs);

    %Switch groups?
    switch_groups = false; %set true to switch groups periodically
    whenToSwitchGroups = 10; %how many timesteps before switching groups

    %Adjacency matrix for group interactions

        %If forming groups randomly:
            A = groups_matrix(S,m); %randomly formed groups of size m in class of S students
        
        %If forming groups homogeneously:
            %xVec = sort(xVec);
            %A = groups_matrix_ordered(S,m); %groups formed homogeneously by anxiety




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Timestep anxiety levels
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    xSoln(:,i)=xVec;  %initializing our solution matrix with initial vector x                    

    while changeInTimeStep>convErr && i < endTime
        i = i+1;
        [xSoln(:,i),changeInTimeStep] = BC_model_steps(A,xVec,epsilon,gam); %Update one time step
        xVec = xSoln(:,i); %update xVec to new anxiety levels
        if switch_groups 
             if mod(i,whenToSwitchGroups)==0 %every few timesteps make new groups
                   A=groups_matrix(S,m);
             end
        end
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(2)
    clf
    for j=1:length(xVec) %index from 1 to number of people in classroom 
        hold on
        plot(1:i, xSoln(j,:), '-','LineWidth',3); %plotting time against our solution matrix
        %title('Math Anxiety in a Classroom');
        xlabel('Timesteps','interpreter','latex');
        ylabel('Math Anxieties','interpreter','latex')
        set(gca, 'FontSize', 16);
       
        axis([1 i 0 1])
    end 

    end_anxiety_Av = mean(xSoln(:,end));
    disp(end_anxiety_Av)

end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% Interaction function, f
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function xMat = f_interaction(xVec,epsilon,gam)
    %input: xVec of current anxieties
    %output: matrix, f_{ij} = f(x_i,x_j) for i \neq j
    %                f_{ii} = xVec   

    xMat = repmat(xVec,[1,length(xVec)]); %S x S matrix
    xMat = (abs(xMat-xMat')<=epsilon).*(gam*xMat)+...
        (xMat-xMat'>epsilon).*((1-gam)+gam*xMat); %no abs here because only high anxiety goes up
    xMat = xMat - diag(diag(xMat)) + diag(xVec);
 end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bounded confidence timestep function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [newxVec,changeInTimeStep] = BC_model_steps(A,xVec,epsilon,gam)
    %input: xVec of current anxieties
    %output: vector of new anxieties

    interactionMat = A.*f_interaction(xVec,epsilon,gam);
    num_interactions = sum(interactionMat>0,2); %number of non-zero interactions
    newxVec = sum(interactionMat,2)./num_interactions;
    changeInTimeStep = sum(abs(xVec - newxVec));
end