clear all

T = csvread('training.csv');%import without row of ones as first row
beta_0=sum(T(:,end)).*1/length(T(:,end)); % intersector is mean of y

Nrows = size(T, 1);
lambda = getMinErrLambda(T); % first calculation of lambda for comparison

[T_ext,paramCombi]=paramCombination(T,lambda);% T is extended with combinations and shifted
[T_fact,selected_factors] = getNonlinFactors(T_ext,lambda);
lambda_fact = getMinErrLambda(T_fact); % new specific calculation of optimal lambda


% Calculate predictors using new lambda estimate
predictors = ridgeRegression(T_fact, lambda_fact);

V = csvread('validation.csv');%import without row of ones as first row

new_params=zeros(size(V,1),size(paramCombi,1));
for i=1:size(paramCombi,1)
    new_params(:,i)=V(:,paramCombi(i,1)).*V(:,paramCombi(i,2)); % combine parameters
end
V_ext=[new_params,V]; %add new rows with combination of parameters

V_fact=shift(V_ext); % shift mean to 0;
for i=1:size(V_fact,2)
    V_fact(:,i)=V_fact(:,i).^selected_factors(i); % add factors
end
estR = V_fact*predictors + beta_0*ones(size(V,1),1);% estimation of time

% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

