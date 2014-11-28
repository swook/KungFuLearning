function perr = calcError(model, X, Y)
    % TODO: Apply new error function
    labels = svmpredict(ones(size(Y)), X, model, '-q');
    dR = labels - Y;
    perr = (sum(5 * (dR > 0)) + sum(dR < 0)) / size(Y, 1);
end

