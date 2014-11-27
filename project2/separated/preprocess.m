function X = preprocess(X)
    % Normalise
    [Nrows, Nfeats] = size(X);

    % Add 0th predictor
    %X = [ones(Nrows, 1) X];

    % Combine features
    % Note: feats are mean intensity, mean & variance of gradient values
    %X(:, 3:3:Nfeats) = sqrt(X(:, 3:3:Nfeats));
end
