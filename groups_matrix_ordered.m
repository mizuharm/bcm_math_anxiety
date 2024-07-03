%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Matrix of random student groups
%
%
%
% Creates random grouping of students in classroom
% Students only interact with others in their group
% Teacher still influences all students
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function A=groups_matrix_ordered(S,m) %S=number of students, m number of groups,
%if mod(S,m)!=0 then adjust groups so that all are at most one away


    A = zeros(S,S); %Adjacency matrix
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Figure out the groups
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    num_of_students_per_group = floor(S/m);
    
    group_order = 1:1:S; %random permutation of [1..S]
    
    num_groups_to_adjust = mod(S,m); %number of groups to adjust
    
    cur_student = 0;
    for i = 1:m
        if i <= num_groups_to_adjust
            num_of_students_per_group = num_of_students_per_group+1;
        end
       group_members = group_order(cur_student+1:cur_student+num_of_students_per_group); %members in the ith group
       cur_student = cur_student+num_of_students_per_group;
       for j = 1:num_of_students_per_group
           for k = 1:num_of_students_per_group
               if j~=k %ignore self connection
                   A(group_members(j),group_members(k)) = 1;
               end
           end
       end     
        if i <= num_groups_to_adjust
            num_of_students_per_group = num_of_students_per_group-1;
        end
    end
    
    % add the extra students
    % for i = 1:num_groups_to_adjust
    %    new_student = group_order(end-i+1);
    %    group_members = group_order((i-1)*num_of_students_per_group+1:i*num_of_students_per_group); %add students to the first group first
    %    for j=1:num_of_students_per_group
    %        A(new_student,group_members(j))=1;
    %        A(group_members(j),new_student)=1;
    %    end
    % end
    
    A = A+eye(S,S);
    imagesc(A);
    