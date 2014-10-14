function T_shift = shift( dataset )
% Shift coordinate system into center of mass of the distribution
    T_shift = (dataset - repmat(mean(dataset(:,1:end)), size(dataset,1), 1));


end

