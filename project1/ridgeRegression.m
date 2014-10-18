function [predictors] = ridgeRegression(T, lambda)
	% Inputs:
	% - T: Training dataset
	%
	% Output:
	% - predictors: Response of regression

	% Response variables
	Y = T(:, end);

	% Input variables
	X = T(:, 1:end-1);
	Nfeat = size(X, 2);

	% Calculate predictors
    %[msg, msgid] = lastwarn; % warning for sparse matrix
    s = warning('off','MATLAB:nearlySingularMatrix');% don't show the warning
	predictors = (X'*X + lambda*eye(Nfeat)) \ (X'*Y);
    warning(s); % activate warning again
	return;

	% SVD of X
	[U, D, V] = svd(X);

	I = eye(size(D, 2));
	%size(X)
	%size(D)
	%size(U)
	%size(Y)
	%size(D'*D)
	%size(lambda*I)
	%size(D'*D+lambda*I)
	%size(D'*U')
	%size((D'*D+lambda*I)\(D'*U'));
	%size(U*D*((D'*D+lambda*I)\(D'*U'))*Y)
	predictors = X \ (U*D*((D'*D+lambda*I)\(D'*U'))*Y);
end
