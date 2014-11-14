function [ est_perr ] = crossValidation(dataset, lambda)
	% Inputs:
	% - dataset: Training dataset
	% - lambda:  Tuning parameter of Ridge Regression
	%
	% Output:
	% - est_perr: Estimated prediction error

	% No. of rows in datasets
	N = size(dataset, 1);

	% No. of training subsets
	K = calculateNSubsets(dataset);

	% No. of rows per training/validation subset
	N_K = floor(N / (K + 1));

	% No. of rows in last subset
	N_L = N - N_K*K;

	% List of prediction errors
	perr_list = [];

	% Pre-allocate T and V subsets
	%T = zeros(N - N_K*K, size(dataset, 1));
	%V = zeros(N_L, size(dataset, 1));

	% For each validation subset
	for i = 1:K % Position of validation subset

		% Calculate range of rows of validation subset
		i_Vstart = (i-1) * N_K + 1;
		if i < K
			i_Vend = i_Vstart + N_K - 1;
		else
			i_Vend = N;
		end

		% Training data subset
		T = dataset([1:i_Vend-1 i_Vend+1:N], :);

		% Validation data subset
		V = dataset(i_Vstart:i_Vend, :);

		% Run regression
		predictors = ridgeRegression(T, lambda);

		% Calculate prediction error
		perr = predictionE(predictors, V, lambda);
		perr_list = [perr_list perr];
	end

	% Calculate estimate of prediction error
	est_perr = mean(perr_list);
end

function [K] = calculateNSubsets(dataset)
	% Engineers' solution to finding no. of training subsets
	%K = min(sqrt(size(dataset, 1)), 10);
	K = floor(sqrt(size(dataset, 1)));
end
