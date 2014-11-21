function runSVM()
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
    C = 40;
    errs = crossval(@(x1, x2)(trainInCV(x1, x2, C)),        ... % Training function
                    T,                                      ... % Dataset
                    'kfold', min(15, round(sqrt(Nrows))),   ... % 20-fold CV
                    'Options', statset('UseParallel', true) ... % Make parallel
                   );
    mean(errs)

    % Model finalised
    model = train(X, Y, C); % Calculate final model
    fprintf('Final model calculated.\n');

    % Load validation dataset
    V = preprocess(csvread('../data/validation.csv'));
    est = svmclassify(model, V);         % Calculate estimates
    csvwrite('../predictions.txt', est); % Write estimates to file
    fprintf('Wrote predictions to file.\n');
end

function X = preprocess(X)
    % Normalise
    [Nrows, Nfeats] = size(X);
    X = X - repmat(mean(X), Nrows, 1);
    X = X./ repmat(std(X), Nrows, 1);

    % Combine features
    % Note: feats are mean intensity, mean & variance of gradient values
    %X(:, 3:3:Nfeats) = sqrt(X(:, 3:3:Nfeats));
end

function perr = trainInCV(Ttrain, Ttest, C)
    Xtrain = Ttrain(:, 1:end-1);
    Ytrain = Ttrain(:, end);
    Xtest = Ttest(:, 1:end-1);
    Ytest = Ttest(:, end);
    perr = calcError(train(Xtrain, Ytrain, C), Xtest, Ytest);
end

% Trains model given training data using selected methods
function model = train(X, Y, Cval)
    % Set asymmetric costs for FPs
    C = ones(size(Y)) .* Cval;
    C(Y < 0) = 5 .* Cval;

    model = svmtrain(X, Y, ...
                     'kernel_function', 'rbf',  ...
                     'rbf_sigma',       1,      ...
                     'method',          'SMO',  ...
                     'autoscale',       false,  ...
                     'boxconstraint',   C,      ...
                     'options',         statset(...
                         'MaxIter', 50000 ...
                     )...
                    );
end

% Calculate prediction error with asymmetric cost accounted for
function perr = calcError(model, X, Y)
    labels = svmclassify(model, X);
    dR = labels - Y;
    perr = (sum(5 * (dR > 0)) + sum(dR < 0)) / size(Y, 1);
end

