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
    C = findOptimalC(T, S, 0.001, 100);

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
end

function X = preprocess(X)
    % Normalise
    [Nrows, Nfeats] = size(X);

    % Add 0th predictor
    %X = [ones(Nrows, 1) X];

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
    min_dV = (VN - V0) / 200;

    while dV > min_dV
        dV = (VN - V0) / 10;
        Vs = V0:dV:VN;

        errs = [];

        fprintf('Checking in %f ~ %f\n', V0, VN);
        for V = Vs
            fprintf('> %s   = %f\t\t| ', name, V);
            %err = crossval(@(x1, x2)(func(x1, x2, V)), T,           ...
            %                'Leaveout', 1,                      ...
            %                'Options', statset('UseParallel', true) ... % Make parallel
            %               );
                            %'kfold', max(30, round(sqrt(Nrows))),   ... % 15-fold VV
            err = crossValidation(T, @(x1, x2)(func(x1, x2, V)));
            errs = [errs err];
            fprintf('  err = %.9f\n', err);
        end
        fprintf('\n');

        % Select V with smallest estimated prediction errors
        [min_value, min_index] = min(errs);
        selected_V = Vs(min_index);

        V0 = max(selected_V - dV, 1e-4);
        VN = selected_V + dV;
    end
end

function perr = trainInCV(Ttrain, Ttest, C, S)
    Xtrain = Ttrain(:, 1:end-1);
    Ytrain = Ttrain(:, end);
    Xtest = Ttest(:, 1:end-1);
    Ytest = Ttest(:, end);

    % Normalise features
    Nrows = size(Xtrain, 1);
    xmean = mean(Xtrain);
    xstd  = std(Xtrain);
    Xtrain = (Xtrain - repmat(mean(Xtrain), Nrows, 1)) ./ repmat(std(Xtrain), Nrows, 1);
    Xtest = (Xtest - repmat(xmean, size(Xtest, 1), 1)) ./ repmat(xstd, size(Xtest, 1), 1);

    perr = calcError(train(Xtrain, Ytrain, C, S), Xtest, Ytest);
end

% Trains model given training data using selected methods
function model = train(X, Y, Cval, Sval)
    Sval = .5 / (Sval*Sval);
    model = svmtrain(Y, X, ...
                     sprintf('-q -s 0 -g %f -c %f -w-1 5 -w1 1 -e 1e-7', Sval, Cval));

    % Set asymmetric costs for FPs
    %C = ones(size(Y)) .* Cval;
    %C(Y < 0) = 5 .* Cval;
    %
    %model = svmtrain(X, Y, ...
    %                 'kernel_function', 'rbf',  ...
    %                 'rbf_sigma',       Sval,      ...
    %                 'method',          'SMO',  ...
    %                 'autoscale',       false,  ...
    %                 'boxconstraint',   C,      ...
    %                 'options',         statset(...
    %                     'MaxIter', 80000 ...
    %                 )...
    %                );
end

% Calculate prediction error with asymmetric cost accounted for
function perr = calcError(model, X, Y)
    %labels = svmclassify(model, X);
    labels = svmpredict(ones(size(Y)), X, model, '-q');
    dR = labels - Y;
    perr = (sum(5 * (dR > 0)) + sum(dR < 0)) / size(Y, 1);
end

