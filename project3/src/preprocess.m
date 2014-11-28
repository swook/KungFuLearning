function X = preprocess(X)
    % Normalise
    [Nrows, Nfeats] = size(X);

    % Add 0th predictor
    %X = [ones(Nrows, 1) X];

    % Combine features
    % Note: feats are mean intensity, mean & variance of gradient values
    meanInt = X(:, 1:3:Nfeats);
    meanGra = X(:, 2:3:Nfeats);
    varGrad = X(:, 3:3:Nfeats);
    stdGrad = sqrt(varGrad);

    %X = addCols(X, meanGra + stdGrad);
    X = addCols(X, meanGra - stdGrad);
    %X = addCols(X, meanGra.*stdGrad);
end

function newX = addCols(oldX, cols)
    newX = [oldX, cols];
end
