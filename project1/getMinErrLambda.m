function selected_lambda = getMinErrLambda(T)
	% Minimum step in searching for min-err-lambda
	lambda0 = 0;
	lambdaN = 100;
	dlambda = lambdaN;
	min_dlambda = 1e-7;

	% Reduce range in which to search for value of lambda at minimum
	% estimated prediction error
	while dlambda > min_dlambda
		dlambda = (lambdaN - lambda0) / 10;
		lambdas = lambda0:dlambda:lambdaN;

		errs = [];

		disp(['Checking for lambda in ', num2str(lambda0), ' ~ ', num2str(lambdaN)]);
		for lambda = lambdas
			%disp(lambda);
			errs = [errs crossValidation(T, lambda)];

			%figure(3)
			%hold on
			%predictors = ridgeRegression(T, lambda)
			%plot(1:length(predictors),log10(predictors),'b')
			%grid on
			%hold on
		end

		% Select lambda with smallest estimated prediction errors
		[min_value, min_index] = min(errs);
		selected_lambda = lambdas(min_index);

		lambda0 = max(selected_lambda - dlambda, 0);
		lambdaN = selected_lambda + dlambda;
		%figure(1)
		%plot(lambdas, errs)


	end

	%figure(3)
	%predictors = ridgeRegression(T,selected_lambda);
	%h=plot(1:length(predictors),log10(predictors),'+-r')
	%legend(h,'optimal \lambda');
	%title('Variation of the predictors as a function of \lambda')
	%ylabel('predictor value (logarithmic)')
	%xlabel('predictor index')
	%grid on
	%hold off

end
