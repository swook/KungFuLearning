function selected_lambda = getMinErrLambda(T,doPlot)
	% Minimum step in searching for min-err-lambda
	lambda0 = 0;
	lambdaN = 100;
	dlambda = lambdaN;
	min_dlambda = 1e-7;
    i=1;
    predictors = ridgeRegression(T, 0)
    plot_matrix=1:length(predictors);
    plot_matrix=plot_matrix';
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

            predictors = ridgeRegression(T, lambda);
            plot_matrix=[plot_matrix,log10(predictors)];
		end

		% Select lambda with smallest estimated prediction errors
		[min_value, min_index] = min(errs);
		selected_lambda = lambdas(min_index);

		lambda0 = max(selected_lambda - dlambda, 0);
		lambdaN = selected_lambda + dlambda;
		%figure(1)
		%plot(lambdas, errs)


    end
    if doPlot
        predictors = ridgeRegression(T,selected_lambda);
        plot_matrix=[plot_matrix,log10(predictors)];
        color=gray(size(plot_matrix,2));
        for i=2:size(plot_matrix,2)
            figure(3)
            hold on
            plot(plot_matrix(:,1),plot_matrix(:,i),'Color',color(size(plot_matrix,2)-i+1,:))
        end
        %legend(h,'optimal \lambda');
        title('Variation of the predictors as a function of \lambda')
        ylabel('predictor value (logarithmic)')
        xlabel('predictor index')
        grid on
        hold off
    end
    
end
