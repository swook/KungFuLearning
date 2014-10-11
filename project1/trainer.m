clear all;

T = importData('training.csv');

% Renormalize data
Nrows = size(T, 1);
%T = (T - repmat(mean(T), Nrows, 1)) ./ repmat(var(T), Nrows, 1);

lambdas = 0.002264:.00000001:.002265;
errs = [];

for lambda = lambdas
	lambda
	errs = [errs crossValidation(T, lambda)];
end

plot(lambdas, errs);

% Select lambda with smallest estimated prediction errors
[min_value, min_index] = min(errs);
selected_lambda = lambdas(min_index);

% Final predictors
predictors = ridgeRegression(T, selected_lambda)

% Calculate estimated results from validation set
V = importData('validation.csv');
estR = V * predictors;

% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

