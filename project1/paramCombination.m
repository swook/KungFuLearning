function [T_out,paramCombi]  = paramCombination( T,lambda )
% T is a matrix with non-shifted test data (with y)
%
% paramCombination multiplies the different columns and adds that new
% column to the data. It then tests if this brings the error down by a
% certain threshold. If yes, the new column consisting of the
% multiplication of these two parameters is added to the data (at the end).
%
% The output consists of the matrix T_out, which contains the original and
% the new data.
%




    n_param = size(T,2)-1; % number of parameters
    err_org = crossValidation(T,lambda); % original error

    sets = {[1:n_param], [1:n_param]};
    [x y] = ndgrid(sets{:});
    combinations = [x(:) y(:)];% all possible combinations of parameter (1,1) to (14,14)



    new_param=zeros(size(T,1),1);
    T_new=zeros(size(T,1),size(T,2)+1);
    paramCombi=[];

    threshold = 2; % in percent
    j=0;
    for i=1:size(combinations,1)
        param1=combinations(i,1);
        param2=combinations(i,2);
        if param1<param2 % param1*param2 is the same as param2*param1
            new_param=T(:,param1).*T(:,param2); % multiplying the 2 param
            T_new=[new_param,T]; % add new row
            err_new = crossValidation(T_new,lambda); % calculate new error
            err_perc = 100*(err_org-err_new)/err_org; % change in percent with previous error
            if err_perc>threshold
                j=j+1;
                disp(['Combination of parameters ',num2str(param1),' and '...
                ,num2str(param2),' makes it better by ', num2str(err_perc),'%'])
                paramCombi(j,:)=[param1,param2];
                disp(['This combination is added in column ',num2str(n_param+j)])
            end
        end
    end

    new_params=zeros(size(T,1),size(paramCombi,1));
    for i=1:size(paramCombi,1)
        new_params(:,i)=T(:,paramCombi(i,1)).*T(:,paramCombi(i,2));
    end
    T_out=[T(:,1:end-1),new_params,T(:,end)]; %add new rows right before end
    err_paramC=crossValidation(T_out,lambda);
    display(['The prediction error after combination is ',num2str(err_paramC)])
    
end

