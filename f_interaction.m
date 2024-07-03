 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% Interaction function, f, of the
 %% bounded confidence model.
 %%
 %%
 %% Input: xVec - vector of anxieties
 %%        epsilon - threshold of good/bad interaction
 %%        gam - sensitivity/receptiveness parameter
 %%
 %%        f(x,y) = gam*x if |x-y|<epsilon
 %%        f(x,y) = 1-gam+gam*x if x>epsilon+y
 %% Output:
 %%          xMat - f_{ij} = f(x_i,x_j) for i \neq j
 %%                 f_{ii} = xVec
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
