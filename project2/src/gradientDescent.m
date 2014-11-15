function [w] = gradientDescent(T, C, varargin)
    % Inputs:
    % - T: Testing set
    % - C: Hyperparameter
    % - w0: Starting w (Optional)
    %
    % Output:
    % - w: Parameters


    [Nrows, Ncols] = size(T);

    % Initial w is zero-vector
    w = zeros(Ncols - 1, 1);
    beta = 1;           %initial step size
    
    if length(varargin) > 2
        w = varargin{3}; 
    end

    % Classifications
    y = T(:, end);
    y_mean = mean(y);

    % Predictors
    x = T(:, 1:end-1);

    i = 0;
    beta_max=1e10;
    err_limit = 1e-2;
    dw = ones(size(w));
    err_old=1e10;

    grad = zeros(size(w));
    chk  = zeros(Nrows, 1); % [y_i * w' * x_i]
    perr_old=1e3;

    % Until error sufficiently low
    while true

        % Increment counter
        i = i + 1;
        % Learning rate
        %beta = 1e-3 / i / C;
        %if C>=1
        %    beta=1/(i*C);
        %end

        %% Stochastic, one sample at a time
%         grad = 2 * w / Nrows;
% 
%         idx = randi(Nrows);
%         if y(idx) * dot([y_mean; w], [1, x(idx, :)]') < 1
%            if y(idx) > 0
%                grad = grad - 1 * C * y(idx) * x(idx, :)';
%            else
%                grad = grad - 5 * C * y(idx) * x(idx, :)';
%            end
%         end

        

        %% Check whole dataset

        chk = y .* (x * w);
        idxs = find(chk < 1);     % All indices that match criterion

        % Calculate gradient
        coeff = ones(size(idxs));
        coeff(y(idxs) <= 0) = 5; % Penalize FPs more

        grad = w - C .* x(idxs, :)' * (coeff .* y(idxs));

        % Apply gradient descent
        dw = beta * grad;
        w_new = w - dw;
        err_new=norm(dw, 2);
        
        perr = predictionE(w_new,T);
        if err_new< err_limit % converges
            break;
        end
        
        if mod(i, 1e3) == 0
           disp([num2str(err_new) '  ' num2str(perr)]);
        end
        
        if err_new<err_old %if error decreases
            beta=min(beta*1.3,beta_max); % increase learning rate
        else
            beta=max(beta/2,1/i); %else decrease learning rate
            w_new=w; % reset parameters
        end

        err_old=err_new;
        w=w_new;
        
    end
end
