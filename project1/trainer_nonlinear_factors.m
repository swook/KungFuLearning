clear all;

T = csvread('training.csv');%import without row of ones as first row
beta_0=sum(T(:,end)).*1/length(T(:,end)); % intersector is mean of y
T_shift=shift(T); % put mean of each column to 0
Nrows = size(T, 1);

lambda = getMinErrLambda(T_shift);
[T_fact,selected_factors] = getNonlinFactors(T_shift,lambda);
lambda_fact = getMinErrLambda(T_fact);

% Calculate predictors using preliminary lambda estimate
predictors = ridgeRegression(T_fact, lambda_fact);

V = csvread('validation.csv');%import without row of ones as first row
V_shift=shift(V);
V_fact=V_shift;
for i=1:size(V_fact,2)
    V_fact(:,i)=V_fact(:,i).^selected_factors(i);
end
estR = V_fact*predictors + beta_0*ones(size(V,1),1);

% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

