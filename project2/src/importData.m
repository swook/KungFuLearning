function dataset = importData(pathname)
    pathname = ['../data/' pathname];
    dataset = csvread(pathname);

    % Renormalize data
    Nrows = size(dataset, 1);
    X = dataset(:, 1:end-1);
    y = dataset(:, end);

    % Z-score standardization
    X = X - repmat(mean(X), Nrows, 1);
    X = X./ repmat(std(X), Nrows, 1);

    % min-max scaling
    %X = (X - repmat(min(X), Nrows, 1)) ./ repmat(max(X) - min(X), Nrows, 1);

    dataset = [X, y];

    % Add 0th predictor (y-intercept)
    dataset = [ones(Nrows, 1) dataset];
end
