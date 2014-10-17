function [T_factorized,selected_factors] = getNonlinFactors(T,lambda)
% T is a matrix with test data (with y) with a mean shifted to 0
% selected factors tries linear (factor=1) and quadratic relationships for
% each parameter
    n_param = size(T,2)-1; % number of parameters
    selected_factors = ones(n_param,1); %initialization
    err_org = crossvalidation(T,lambda) % original error

    % first loop, only one parameter gets its factor each time
    for i=1:n_param
        err=err_org;
        for j=1:2:5
            T_factorized=T;
%             if mod(j,2)==0 % for pair powers, negative values have to stay negative!
%                 for k=1:numel(T_factorized(:,i))
%                     if T_factorized(k,i)<0
%                         T_factorized(k,i)=-(T_factorized(k,i)^j);
%                     else
%                         T_factorized(k,i)=T_factorized(k,i)^j;
%                     end
%                 end
%             else
%                 T_factorized(:,i)=T_factorized(:,i).^j;
%             end
            T_factorized(:,i)=T_factorized(:,i).^j;
            err_new = crossValidation(T_factorized,lambda);
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
    err_fact=crossValidation(T_factorized,lambda)
end

