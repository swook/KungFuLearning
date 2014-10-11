function err = predictionE(predictors, V, lambda)
	% Inputs:
	% - predictors: Response of regression
	% - V:          Validation dataset
	% - lambda:     Tuning parameter of Ridge Regression
	%
	% Output:
	% - err: Prediction error

	% Result from validation subset
	realR = V(:, end);

	% Calculate results from estimated predictors
	estR = V(:, 1:end-1) * predictors;

	% Calculate prediction error
	dR = realR - estR;
	err = dot(dR, dR);
end

