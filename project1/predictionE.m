function err = predictionE(predictors, V, lambda)
	% Inputs:
	% - predictors: Response of regression
	% - V:          Validation dataset
	% - lambda:     Tuning parameter of Ridge Regression
	%
	% Output:
	% - err: Prediction error

	[Nrows, Ncols] = size(V);

	% If no feature present in dataset, error is infinite
	if size(V, 2) < 2
		err = inf;
		return;
	end

	% Result from validation subset
	realR = V(:, end);

	% Calculate results from estimated predictors
	estR = V(:, 1:end-1) * predictors;

	% Calculate prediction error
	dR = abs(realR - estR);
    % Prediction error
	err = dot(dR, dR);
    
end

