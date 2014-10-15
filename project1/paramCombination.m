function [T_out,paramCombi]  = paramCombination( T,lambda )
% T is a matrix with non-shifted test data (with y) 
%
% paramCombination multiplies the different columns and adds that new
% column to the data. It then tests if this brings the error down by a
% certain threshold. If yes, the new column consisting of the
% multiplication of these two parameters is added to the data.
%
% The output consists of the matrix T_out, which contains the original and 
% the new data, and which is shifted in order to have a zero-mean. 
% 


    

    n_param = size(T,2)-1; % number of parameters
    err_org = crossvalidation(T,lambda) % original error

    sets = {[1:n_param], [1:n_param]};
    [x y] = ndgrid(sets{:});
    combinations = [x(:) y(:)];% all possible combinations of parameter (1,1) to (14,14)

    
   
    new_param=zeros(size(T,1),1);
    T_new=zeros(size(T,1),size(T,2)+1);
    paramCombi=[];

    threshold = 10; % in percent
    j=0;
    for i=1:size(combinations,1)
        param1=combinations(i,1);
        param2=combinations(i,2);
        if param1<param2 % param1*param2 is the same as param2*param1
            new_param=T(:,param1).*T(:,param2); % multiplying the 2 param
            T_new=[new_param,T]; % add new row
            err_new = crossvalidation(T_new,lambda); % calculate new error
            err_perc = 100*(err_org-err_new)/err_org; % change in percent with previous error
            if err_perc>threshold
                j=j+1;
                disp(['Combination of parameters ',num2str(param1),' and '...
                ,num2str(param2),' makes it better by ', num2str(err_perc),'%'])
                paramCombi(j,:)=[param1,param2];
            end
        end
    end
    
    new_params=zeros(size(T,1),size(paramCombi,1));
    for i=1:size(paramCombi,1)
        new_params(:,i)=T(:,paramCombi(i,1)).*T(:,paramCombi(i,2));
    end
    T_out=[new_params,T]; %add new rows
    T_out=shift(T_out); % shift to prevent non-zero means
             

end

