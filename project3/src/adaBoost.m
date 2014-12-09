function [models,alpha] = adaBoost( X,Y,Nclasses,Nclassifiers )
% Adaboost method 
% to predict using output : Y=sign(sum(alpha(b)*svmpredict(...,model(b))));
[Nrows,Nfeats]=size(X);
% initialize observation weights 
w=1/Nrows*ones(Nrows);
c=zeros(Nclassifiers,Nclasses-1,Nfeats);
classifier=zeros(Nclasses-1,Nfeats);
for b=1:Nclassifiers
	models(b) = svmtrain(Y, X, '-e 1e-2');
	outputs = svmpredict(ones(size(X, 1), 1), X, model);
	wrongPredIdx=(Y~=outputs);
	c(b,:)=model.sv_coef'*full(mode.SVs);
	norm=sum(w);
	epsilon=sum(w(wrongPredIdx));
	alpha(b)=log((1-epsilon)/epsilon);
	w(WrongPredIdx)=w(wrongPredIdx).*exp(alpha(b));
end
end
