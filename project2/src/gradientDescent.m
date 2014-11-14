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

    if length(varargin) > 2
        w = varargin{3};
    end

    % Classifications
    y = T(:, end);

    % Predictors
    x = T(:, 1:end-1);

    i = 0;
    beta = 1;
    err_limit = 1e-7;
    err = ones(size(w));

    grad = zeros(size(w));
    chk  = zeros(Nrows, 1); % [y_i * w' * x_i]

    % Until error sufficiently low
    while true

        % Increment counter
        i = i + 1;

        % Learning rate
        beta = 1 / i;
        if C>=1
            beta=1/(i*C);
        end

        % Stochastic
        grad = 2 * w / Nrows;

        %for i = 1:2
            idx = randi(Nrows);

            if y(idx) * dot(w, x(idx, :)') < 1
                if y(idx) > 0
                    grad = grad - 1 * C * y(idx) * x(idx, :)';
                else
                    grad = grad - 5 * C * y(idx) * x(idx, :)';
                end
            end
        %end

        %% Check per row
        %chk = y .* (x * w);
        %chk'
        %idxs = chk < 1;     % All indices that match criterion

        %% Calculate gradient
        %grad = 2 * w;
        %grad = grad - C * x(idxs, :)' * y(idxs);

        % Apply gradient descent
        err = beta * grad;
        w = w - err;

        if norm(err, 2) < err_limit
            break;
        end

        if mod(i, 1e1) == 0
            disp(predictionE(w, T));
        end

    end
end
