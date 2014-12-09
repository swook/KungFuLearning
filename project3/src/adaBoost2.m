function [models,alpha] = adaBoost2 (X,Y,Nclasses)

[Nrows,Nfeats]=size(X);

w=1/Nrows*ones(Nrows,1);
c=zeros(Nclassifiers,Nclasses-1,Nfeats);
classifier=zeros(Nclasses-1,Nfeats);
models=zeros(Nclassifiers,1);
Xweighted=X;
for b=1:Nfeats
	models(b) = svmtrain(Y, Xweighted(:,b),'-q'); % classify using one feature
	outputs = svmpredict(ones(size(X, 1), 1), X(:,b), models(b));
	wrongPredIdx=(X(:,b)==1 && Y~=outputs);
	%c(b,:)=models(b).sv_coef'*full(mode.SVs);
	norm=sum(w);
	epsilon=sum(w(wrongPredIdx));
	alpha(b)=log((1-epsilon)/epsilon);
	w(WrongPredIdx)=w(wrongPredIdx).*exp(alpha(b));
	for i=1:Nrows
		Xweighted(i,b)=Xweighted(i,b)*w(i);
	end

end
end
