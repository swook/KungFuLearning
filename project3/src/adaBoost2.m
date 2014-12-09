function [models,alpha] = adaBoost2 (X,Y,Nclasses)

[Nrows,Nfeats]=size(X);

w=1/Nrows*ones(Nrows,1);
%c=zeros(Nclasses-1,Nfeats);
classifier=zeros(Nclasses-1,Nfeats);
models=cell(Nfeats,1);
Xweighted=X;
for b=1:Nfeats
        fprintf('%d\n', b);
	models{b} = svmtrain(Y, Xweighted(:,b),'-q'); % classify using one feature
        idx=find(X(:,b)>0);
	outputs = svmpredict(ones(length(idx), 1), X(idx, b), models{b});
	wrongPredIdx=(Y(idx)~=outputs);
	%c(b,:)=models(b).sv_coef'*full(mode.SVs);
	norm=sum(w);
	epsilon=sum(w(wrongPredIdx));
	alpha(b)=log((1-epsilon)/epsilon);
	w(wrongPredIdx)=w(wrongPredIdx).*exp(alpha(b));
	for i=1:Nrows
		Xweighted(i,b)=Xweighted(i,b)*w(i);
	end

end
end
