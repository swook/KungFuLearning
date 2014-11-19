function [w, perr] = pegasos(T, C)
    % Inputs:
    % - T: Testing set
    % - C: Hyperparameter
    %
    % Output:
    % - w: Parameters


    [N, Ncols] = size(T);
    Nfeats = Ncols - 1;

    % Initial w is zero-vector
    w  = ones(Nfeats, 1); % Weight vector
    w_ = ones(size(w));   % Half-step w for projection step

    x  = T(:, 1:Nfeats); % Predictors
    y  = T(:, end);      % Classifications

    x_ = x;              % Subset x (for use within loop)
    y_ = y;              % Subset y (for use within loop)

    dw = ones(size(w));

    k         = min(10, round(sqrt(N))); % Batch size
    t         = 1;                       % Iteration step
    lambda    = 2 / (N * C);             % Regularisation parameter
    sqlambda  = sqrt(lambda);
    eta       = 1 / (lambda * t);        % Learning rate
    e_lim     = 5e-5/sqlambda;           % Error limit
    perr_min  = 1;                       % Lowest prediction error so far
    perr_minw = ones(size(w));

    w = ones(size(w)) / sqrt(Nfeats) / sqlambda;

    while true % Loop until stopping criterion reached

        %% Preparation
        eta  = 1 / (lambda * t); % Learning rate
        idxs = randi(N, k, 1);   % Get random indices to batch
        x_   = x(idxs, :);       % Get selected samples
        y_   = y(idxs, :);

        %% Update step

        % Find wrongly classified points (FP, FN)
        Midxs = find(y_ .* (x_ * w) < 1);
        Mn    = length(Midxs);
        Mx    = x_(Midxs, :);
        My    = y_(Midxs);

        % Apply assymetric cost for FPs
        coeff         = ones(size(My));
        coeff(My < 0) = 5;

        % Add cost contributions from them
        dw = lambda*w; % Cost from all points regardless
        if Mn > 0
            dw = dw - (1 / Mn) * (Mx' * (coeff .* My));
        end

        % Calculate final w pre-projection
        w_ = w - eta*dw;

        %% Projection step
        w_next = min(1, 1 / (sqlambda*norm(w_, 2))) * w_;
        %e      = w_next - w;
        w      = w_next;

        %% Checking step
        %e_norm = norm(e, 2);        % Norm of current dw
        perr   = predictionE(w, T); % Prediction error for debugging

        % Only print every 1000 steps
        %if mod(t, 1e3) == 0
        %   disp(sprintf('%f\t%f\n', perr, perr_min));
        %end

        % Update min. prediction err so far
        if perr < perr_min
            perr_minw = w;
            perr_min  = perr;
        end

        % Forget about checking errors, just check no. of iters
        if t > 1e5
            w    = perr_minw;
            perr = perr_min;
            break;
        end

        t = t + 1; % Increment iteration step (time)

    end
end
