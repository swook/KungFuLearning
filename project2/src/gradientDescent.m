function [w] = gradientDescent(T, C)
    % Inputs:
    % - T: Testing set
    % - C: Hyperparameter
    %
    % Output:
    % - w: Parameters

    [Nrows, Ncols] = size(T);

    % Initial w is zero-vector
    w = zeros(Ncols - 1, 1);

    % Classifications
    y = T(:, end);

    % Predictors
    x = T(:, 1:end-1);

    i = 0;
    beta = 1;
    err_limit = 1e-3;
    err = ones(size(w));

    grad = zeros(size(w));
    chk  = zeros(Nrows, 1); % [y_i * w' * x_i]

    % Until error sufficiently low
    while norm(err, 2) > err_limit
        if mod(i, 1e3) == 0
            disp(sum(err))
        end

        % Increment counter
        i = i + 1;

        % Learning rate
        beta = .01;

        % Check per row
        chk = y .* (x * w);
        chk'
        idxs = chk < 1;     % All indices that match criterion

        % Calculate gradient
        grad = 2 * w;
        grad = grad - C * x(idxs, :)' * y(idxs);

        % Apply gradient descent
        err = beta * grad;
        w = w - err;

    end
end
