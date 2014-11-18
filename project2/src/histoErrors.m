function [ output_args ] = histoErrors( w,T )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    
    [Nrows, Ncols] = size(T);

    % Result from validation subset
    realR = T(:, end);

    % Calculate results from estimated predictors
    estR = (T(:, 1:end-1) * w) > 0;
    estR = estR * 2 - 1;
    
    %idx=(realR(:)~=estR(:));
    j=1;
    dR=estR-realR;
    for i=1:Nrows
        if dR(i)~=0 
            T_err(j,:)=T(i,:);
            j=j+1;
        end
    end
    disp(['Number of errors : ',num2str(size(T_err,1))])
    close all
    histograms(T,1);
    histograms(T_err,2);
        
    

end

