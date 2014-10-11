function err = predictionE(predictors, V)
	% Inputs:
	% - predictors: Response of regression
	% - V:          Validation dataset
	%
	% Output:
	% - err: Prediction error

	% Result from validation subset
	realR = V(:, end);

	% Calculate results from estimated predictors
	estR = V(:, 1:end-1) * predictors;

	% Calculate prediction error
	dR = realR - estR;
	err = mean(dR .^ 2);
end

