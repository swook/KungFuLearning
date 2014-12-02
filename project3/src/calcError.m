function perr = calcError(Yhat, Y)
    % Yhat_* : predicted values
	 % Y_* : true values
    Yhat_country = Yhat / 1000;
    Yhat_city = mod(Yhat, 1000);
    
    Y_country = Y / 1000;
    Y_city = mod(Y, 1000);
    
    perr = sum(Yhat_city~=Y_city) + 0.25*sum(Yhat_country~=Y_country);
end
