function dataset = importData(pathname)
    pathname = ['../data/' pathname];
    dataset = csvread(pathname);

    % Renormalize data
    Nrows = size(dataset, 1);
    X = dataset(:, 1:end-1);
    y = dataset(:, end);
    X = (X - repmat(mean(X), Nrows, 1)) ./ repmat(var(X), Nrows, 1);
    dataset = [X, y];

    % Add 0th predictor (y-intercept)
    dataset = [ones(size(dataset, 1), 1) dataset];
end
