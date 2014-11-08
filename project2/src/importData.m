function dataset = importData(pathname)
    pathname = ['../data/' pathname];
    dataset = csvread(pathname);

    % Renormalize data
    Nrows = size(dataset, 1);
    dataset = (dataset - repmat(mean(dataset), Nrows, 1)) ./ repmat(var(dataset), Nrows, 1);

    % Add 0th predictor (y-intercept)
    %dataset = [ones(size(dataset, 1), 1) dataset];
end
