function [T_factorized,selected_factors] = getNonlinFactors(T,lambda)
% T is a (non-shifted) matrix with test data (with y) 
% selected factors tries linear (factor=1), quadratic etc. relationships for
% each parameter
    n_param = size(T,2)-1; % number of parameters
    selected_factors = ones(n_param,1); %initialization
    err_org = crossValidation(T,lambda); % original error
    
    % first loop, only one parameter gets its factor each time
    for i=1:n_param
        err=err_org;
        j=-2; 
        while j<5;  % while loop to be able to skip 0
            if j==0 % skip 0 power
                j=j+0.5;% increment
            end
            T_factorized=T;
            T_factorized(:,i)=T_factorized(:,i).^j;
            err_new = crossValidation(T_factorized,lambda);
            if err_new<err
                selected_factors(i)=j;
                err=err_new;
            end
            j=j+0.5; % increment
        end
    end

    % now combine these factorized parameters
    T_factorized=T;
    for i=1:n_param
        T_factorized(:,i)=T_factorized(:,i).^selected_factors(i);
    end
    err_fact=crossValidation(T_factorized,lambda);
    display(['The prediction error after factorization is ',num2str(err_fact)])

end

