function [T_factorized,selected_factors] = getNonlinFactors(T,lambda)
% T is a matrix with test data (with y) with a mean shifted to 0
% selected factors tries linear (factor=1) and quadratic relationships for
% each parameter
    n_param = size(T,2)-1; % number of parameters
    selected_factors = ones(n_param,1); %initialization
    err = crossvalidation(T,lambda) % original error
    
    % first loop, only one parameter gets its factor each time
    for i=1:n_param
        for j=0.5:0.5:5
            T_factorized=T;
            T_factorized(:,i)=T_factorized(:,i).^j;
            err_new = crossvalidation(T_factorized,lambda);
            if err_new<err
                selected_factors(i)=j;
                err=err_new;
            end
        end
    end
    
    % now combine these factorized parameters 
    T_factorized=T;
    for i=1:n_param
        T_factorized(:,i)=T_factorized(:,i).^selected_factors(i);
    end
    err_fact=crossvalidation(T_factorized,lambda)
end

