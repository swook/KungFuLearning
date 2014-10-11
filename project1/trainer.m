clear all;

T = importData('training.csv');

% Renormalize data
Nrows = size(T, 1);
%T = (T - repmat(mean(T), Nrows, 1)) ./ repmat(var(T), Nrows, 1);

% Minimum step in searching for min-err-lambda
lambda0 = 0;
lambdaN = 100;
dlambda = lambdaN;
min_dlambda = 1e-7;

% Reduce range in which to search for value of lambda at minimum
% estimated prediction error
while dlambda > min_dlambda
	dlambda = (lambdaN - lambda0) / 20;
	lambdas = lambda0:dlambda:lambdaN;

	errs = [];

	for lambda = lambdas
		lambda
		errs = [errs crossValidation(T, lambda)];
	end

	% Select lambda with smallest estimated prediction errors
	[min_value, min_index] = min(errs);
	selected_lambda = lambdas(min_index);

	lambda0 = max(selected_lambda - dlambda, 0);
	lambdaN = selected_lambda + dlambda;
end

plot(lambdas, errs);

% Final predictors
predictors = ridgeRegression(T, selected_lambda)

% Calculate estimated results from validation set
V = importData('validation.csv');
estR = V * predictors;

% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

