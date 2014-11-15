    
    V = csvread('validation.csv');

    % Renormalize data
    Nrows = size(V, 1);
    V = (V - repmat(mean(V), Nrows, 1)) ./ repmat(var(V), Nrows, 1);
   
    % Add 0th predictor (y-intercept)
    V = [ones(Nrows, 1) V];
   
    predictions = (V * w) > 0;
    predictions= predictions * 2 - 1;
    csvwrite('predictions.txt', predictions);
