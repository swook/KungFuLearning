function perr = calcError(Yhat_city,Yhat_country, Y_city, Y_country)
    % Yhat_* : predicted values
	 % Y_* : true values
    perr = sum(Yhat_city~=Y_city) + 0.25*sum(Yhat_country~=Y_country) 
end
