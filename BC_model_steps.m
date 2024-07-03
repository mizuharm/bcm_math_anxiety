%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bounded confidence timestep function
%
%
%   Input: A - adjacency matrix of interactions
%          xVec - current student anxiety levels
%          epsilon - threshold of good/bad interactions
%          gam - sensitivity/receptiveness parameter

%   Output: newxVec - vector of updated anxieties, one time step
%           changeInTimeStep - L^1 change of anxieties: sum |xVec_j-newxVec_j|
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [newxVec,changeInTimeStep] = BC_model_steps(A,xVec,epsilon,gam)

    interactionMat = A.*f_interaction(xVec,epsilon,gam);
    num_interactions = sum(interactionMat>0,2); %number of non-zero interactions
    newxVec = sum(interactionMat,2)./num_interactions;
    changeInTimeStep = sum(abs(xVec - newxVec));
end