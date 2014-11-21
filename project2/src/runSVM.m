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
    C = 40;  % Cost parameter
    S = 0.8; % rbf sigma
    C = findOptimalC(T, S, 0.001, 100);
    S = findOptimalS(T, C, 0.001, 5);

    % Model finalised
    model = train(X, Y, C, S); % Calculate final model
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

function C = findOptimalC(T, S, C0, CN)
    C = findOptimal(T, 'C', C0, CN, @(x1, x2, C)(trainInCV(x1, x2, C, S)));
end

function S = findOptimalS(T, C, S0, SN)
    S = findOptimal(T, 'S', S0, SN, @(x1, x2, S)(trainInCV(x1, x2, C, S)));
end

function selected_V = findOptimal(T, name, V0, VN, func)
    Nrows  = size(T, 1);
    dV     = 1;
    min_dV = (VN - V0) / 100;

    while dV > min_dV
        dV = (VN - V0) / 5;
        Vs = V0:dV:VN;

        errs = [];

        fprintf('Checking in %f ~ %f\n', V0, VN);
        for V = Vs
            fprintf('> %s   = %f\t\t| ', name, V);
            err = crossval(@(x1, x2)(func(x1, x2, V)), T,           ...
                            'kfold', max(15, round(sqrt(Nrows))),   ... % 20-fold VV
                            'Options', statset('UseParallel', true) ... % Make parallel
                           );
            errs = [errs mean(err)];
            fprintf('  err = %f\n', errs(end));
        end
        fprintf('\n');

        % Select V with smallest estimated prediction errors
        [min_value, min_index] = min(errs);
        selected_V = Vs(min_index);

        V0 = max(selected_V - dV, 1e-7);
        VN = selected_V + dV;
    end
end

function perr = trainInCV(Ttrain, Ttest, C, S)
    Xtrain = Ttrain(:, 1:end-1);
    Ytrain = Ttrain(:, end);
    Xtest = Ttest(:, 1:end-1);
    Ytest = Ttest(:, end);
    perr = calcError(train(Xtrain, Ytrain, C, S), Xtest, Ytest);
end

% Trains model given training data using selected methods
function model = train(X, Y, Cval, Sval)
    % Set asymmetric costs for FPs
    C = ones(size(Y)) .* Cval;
    C(Y < 0) = 5 .* Cval;

    model = svmtrain(X, Y, ...
                     'kernel_function', 'rbf',  ...
                     'rbf_sigma',       Sval,      ...
                     'method',          'SMO',  ...
                     'autoscale',       false,  ...
                     'boxconstraint',   C,      ...
                     'options',         statset(...
                         'MaxIter', 80000 ...
                     )...
                    );
end

% Calculate prediction error with asymmetric cost accounted for
function perr = calcError(model, X, Y)
    labels = svmclassify(model, X);
    dR = labels - Y;
    perr = (sum(5 * (dR > 0)) + sum(dR < 0)) / size(Y, 1);
end

