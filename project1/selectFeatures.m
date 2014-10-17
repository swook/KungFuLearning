function [ newT, sigCols ] = selectFeatures(T, lambda)
	% selectFeatures
	%
	% Inputs:
	% - T: Input training dataset. \beta_0 not assumed but result assumed
	%      So num. of cols is num. of feats + 1
	%
	% Outputs:
	% - newT:    Selected columns from original dataset including results
	%            size(newT, 1) = numel(sigCols) + 1
	% - sigCols: Column indices for selected features


	% Normalize dataset to be able to identify irrelevant parameters (cols of T)
	[Nrows, Ncols] = size(T);
	Nfeat = Ncols - 1;
	normT = (T - repmat(mean(T), Nrows, 1)) ./ repmat(var(T), Nrows, 1);

	% Calculate predictors
	predictors = ridgeRegression(normT, lambda);

	% Sort predictors to be able to get N largest predictors
	[sortP_val, sortP_idx] = sort(abs(predictors));

	estE = [];
	b0 = ones(Nrows, 1);

	% Reduce no. of features every iteration (with min predictor value)
	for i = 1:Nfeat
		% Filter out predictors
		sigCols = sort(sortP_idx(i:end));
		T_ = [b0 T(:, [sigCols; Ncols])];

		% Find min lambda for reduced dataset
		%lambda = getMinErrLambda(T_);

		% Find predictors for reduced feature dataset
		predictors_ = ridgeRegression(T_, lambda);

		% Append estimated prediction error
		estE = [estE predictionE(predictors_, T_, lambda)];
	end
	estE

	% Find error limit (to filter with) with lowest error
	[minE_val, minE_idx] = min(estE);

	% Assign to output variables
	sigCols = sort(sortP_idx(minE_idx:end));
	newT = T(:, [sigCols; Ncols]);
end
