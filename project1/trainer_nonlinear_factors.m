clear all
disp('--------------------------------------------------------')% for separation

%T = csvread('training.csv');%import without row of ones as first row
%beta_0=sum(T(:,end)).*1/length(T(:,end)); % y-intercept is mean of y
T=importData('training.csv');


Nrows = size(T, 1);
lambda = getMinErrLambda(T); % first calculation of lambda for comparison
err_org = crossValidation(T,lambda); % original error
display(['A first error estimation is ',num2str(err_org)])

[T,selected_factors] = getNonlinFactors(T,lambda);
[T,paramCombi]=paramCombination(T,lambda);% T is extended with combinations of parameters


lambda_new = getMinErrLambda(T); % new specific calculation of optimal lambda


% Calculate predictors using new lambda estimate
predictors = ridgeRegression(T, lambda_new);
prediction_error = crossValidation(T,lambda_new);
display(['The prediction error is ',num2str(prediction_error)])
[perr_PS,var_PS] = crossValidation_final(T,lambda_new);
display(['The prediction error as calculated for the submission is ',num2str(perr_PS)])
display(['The variance of this error is ',num2str(var_PS)])


%V = csvread('validation.csv');
V=importData('validation.csv');

new_params=zeros(size(V,1),size(paramCombi,1));
for i=1:size(V,2)
    V(:,i)=V(:,i).^selected_factors(i); % add factors
end
for i=1:size(paramCombi,1)
    new_params(:,i)=V(:,paramCombi(i,1)).*V(:,paramCombi(i,2)); % combine parameters
end
V=[V,new_params]; %add new rows with combination of parameters at the end


estR = V*predictors;% estimation of time


% Write our predictions (of time) to file
csvwrite('predictions.txt', estR);

