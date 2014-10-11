training = csvread('training.csv');

% Renormalize data
Nrows = size(training, 1);
training = (training - repmat(mean(training), Nrows, 1)) ./ repmat(var(training), Nrows, 1);

lambdas = -100:1:100;
errs = [];

for lambda = lambdas
	lambda
	errs = [errs crossValidation(training, lambda)];
end

plot(lambdas, errs);
