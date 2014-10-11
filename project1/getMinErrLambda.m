function selected_lambda = getMinErrLambda(T)
	% Minimum step in searching for min-err-lambda
	lambda0 = 0;
	lambdaN = 100;
	dlambda = lambdaN;
	min_dlambda = 1e-6;

	% Reduce range in which to search for value of lambda at minimum
	% estimated prediction error
	while dlambda > min_dlambda
		dlambda = (lambdaN - lambda0) / 20;
		lambdas = lambda0:dlambda:lambdaN;

		errs = [];

		for lambda = lambdas
			disp(lambda);
			errs = [errs crossValidation(T, lambda)];
		end

		% Select lambda with smallest estimated prediction errors
		[min_value, min_index] = min(errs);
		selected_lambda = lambdas(min_index);

		lambda0 = max(selected_lambda - dlambda, 0);
		lambdaN = selected_lambda + dlambda;
	end

	plot(lambdas, errs);
end
