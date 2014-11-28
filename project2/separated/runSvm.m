% Load training dataset
    T = csvread('../data/training.csv');
    fprintf('Loaded dataset.\n');

    % Preprocess dataset
    X = preprocess(T(:, 1:end-1));
    Y = T(:, end);
    fprintf('Preprocessed dataset.\n');

    [Nrows, Nfeats] = size(X);

    % Cross-validation to find optimal C
    % TODO: Range over values of C and find optimal C
    C = 1.1;  % Cost parameter C=1.25
    S = 0.55; % rbf sigma  S=0.55
%     C = findOptimalC(T, S, 0.0001, 4);
%     S = findOptimalS(T, C, 0.0001, 2);
    [C,S]=findOptimal2Param(T,0.01,1,0.1,1);
    
    % Model finalised
    Xmean = mean(X);
    Xstd = std(X);
    X = (X - repmat(Xmean, Nrows, 1)) ./ repmat(Xstd, Nrows, 1);
    model = train(X, Y, C, S); % Calculate final model
    fprintf('Final model calculated.\n');
    fprintf('Predicted error: %f.\n\n', calcError(model, X, Y));

    % Load validation dataset
    V = preprocess(csvread('../data/validation.csv'));
    Nrows = size(V, 1);
    V = (V - repmat(Xmean, Nrows, 1)) ./ repmat(Xstd, Nrows, 1);
    %est = svmclassify(model, V);         % Calculate estimates
    est = svmpredict(ones(size(V, 1), 1), V, model, '-q'); % Calculate estimates
    csvwrite('../predictions.txt', est); % Write estimates to file
    fprintf('Wrote predictions to file.\n');