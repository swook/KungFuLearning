clear all;

T = importData('training.csv');

% Initial lambda search
lambda = getMinErrLambda(T);

%% Discard insignificant predictors
% Normalize dataset to be able to identify irrelevant parameters (cols of T)
Nrows = size(T, 1);
normT = T(:, 2:end);
normT = (normT - repmat(mean(normT), Nrows, 1)) ./ repmat(var(normT), Nrows, 1);


% Calculate predictors using preliminary lambda estimate
predictors = ridgeRegression(normT, lambda)

% Only consider predictors above certain value in ln scale
predictors = log10(abs(predictors))
figure(2)
plot(1:numel(predictors), predictors,'r');
hold on
sigcols = find(predictors >  -4) + 1; % First predictor of T is special (and important)
T = T(:, [1; sigcols; size(T, 2)]);

% Find min err lambda again with reduced dataset
%lambda = getMinErrLambda(T);

% Final predictors
predictors = ridgeRegression(T, lambda);

% Calculate estimated results from validation set
V = importData('validation.csv');

% Re-insert 0s for insignificant predictors
newpredictors = zeros(size(V, 2), 1);
newpredictors([1; sigcols]) = predictors


% param_names = [{Width,ROB size,IQ size,LSQ size,RF sizes,RF read ports,...
%     RF write ports,Gshare size, BTB size, Branches allowed, L1 Icache size,...
%     L1 Dcache size, L2 Ucache size, Depth}]
figure(2)
newpredictors_plot=log10(abs(newpredictors));
plot(1:numel(newpredictors),newpredictors_plot,'x-')
hold off

estR = V * newpredictors;

% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

