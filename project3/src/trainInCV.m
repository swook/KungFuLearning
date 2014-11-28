function perr = trainInCV(Ttrain, Ttest, C, S)
    Xtrain = Ttrain(:, 1:end-1);
    Ytrain = Ttrain(:, end);
    Xtest = Ttest(:, 1:end-1);
    Ytest = Ttest(:, end);

    % Normalise features
    Nrows = size(Xtrain, 1);
    xmean = mean(Xtrain);
    xstd  = std(Xtrain);
    Xtrain = (Xtrain - repmat(xmean, Nrows, 1)) ./ repmat(xstd, Nrows, 1);
    Xtest = (Xtest - repmat(xmean, size(Xtest, 1), 1)) ./ repmat(xstd, size(Xtest, 1), 1);

    perr = calcError(train(Xtrain, Ytrain, C, S), Xtest, Ytest);
end
