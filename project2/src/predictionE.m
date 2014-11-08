function err = predictionE(w, V)
    % Inputs:
    % - w: Parameters
    % - V: Validation dataset
    %
    % Output:
    % - err: Prediction error

    [Nrows, Ncols] = size(V);

    % If no feature present in dataset, error is infinite
    if size(V, 2) < 2
        err = inf;
        return;
    end

    % Result from validation subset
    realR = V(:, end);

    % Calculate results from estimated predictors
    estR = (V(:, 1:end-1) * w) > 0;
    estR = estR * 2 - 1;

    % Calculate prediction error
    dR = estR - realR;

    err = (sum(5 * (dR > 0)) + sum(dR < 0)) / Nrows;
end

