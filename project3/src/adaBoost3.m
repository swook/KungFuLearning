function [models,alpha] = adaBoost3 (X,Y)

[Nrows,Nfeats]=size(X);

w=(1/Nrows)*ones(Nrows,1);
models=cell(Nfeats,1);
alpha = zeros(Nfeats,1);
N_resample = 5000;
for b=1:Nfeats
    fprintf('%d\n', b);
    % Resampling
    idx_resample = randsample(Nrows,N_resample,true,w);
    X_resample = X(idx_resample,:);
    Y_resample = Y(idx_resample,:);
    % Classify
    models{b} = svmtrain(Y_resample, X_resample(:,b),'-q'); % classify using one feature
    % Predict and compute error
    output = svmpredict(1,1, models{b},'-q');
    misclassified = (X(:,b)~=(Y==output));
    err = sum(misclassified.*w);
    % Update alpha
    if err > 0.5
        disp('Error to high')
        continue
    end
    if err < 1e-10
        err = 1e-10;
    end
    alpha(b) = 0.5*log((1-err)/err);
    % Update weights
    for i = 1:Nrows
        w(i) = w(i)*exp(-alpha(b)*((Y(i)==output)));
    end
    w = w./sum(w);
end
end