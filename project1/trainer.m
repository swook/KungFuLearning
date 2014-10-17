clear all;

T = importData('training.csv');

% Initial lambda search
lambda = getMinErrLambda(T);

% Discard insignificant predictors
%[newT, sigCols] = selectFeatures(T(:, 2:end), lambda);
%sigCols = sigCols + 1; % Account for 0th predictor
%T = T(:, [1; sigCols; size(T, 2)]);

% Find min err lambda again with reduced dataset
lambda = getMinErrLambda(T);

% Final predictors
predictors = ridgeRegression(T, lambda);

% Calculate estimated results from validation set
V = importData('validation.csv');

% Re-insert 0s for insignificant predictors
newpredictors = zeros(size(V, 2), 1);
%newpredictors([1; sigCols]) = predictors;
newpredictors = predictors;


% param_names = [{Width,ROB size,IQ size,LSQ size,RF sizes,RF read ports,...
%     RF write ports,Gshare size, BTB size, Branches allowed, L1 Icache size,...
%     L1 Dcache size, L2 Ucache size, Depth}]
%figure(2)
%newpredictors_plot=log10(abs(newpredictors));
%plot(1:numel(newpredictors),newpredictors_plot,'x-')
%hold off

estR = V * newpredictors;

% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

