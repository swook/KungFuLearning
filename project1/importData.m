function dataset = importData(pathname)
	dataset = csvread(pathname);

	% Add 0th predictor (y-intercept)
	dataset = [ones(size(dataset, 1), 1) dataset];
end
