function [class] = predictAdaBoost(T,models,alpha,label)

prediction = zeros(size(T,1),numel(label));
alpha = abs(alpha);
for m = 1:numel(alpha)
    predict_label = svmpredict(1,1,models{m});
    idx_label = find(label == predict_label);
    idx_word = find(T(:,m)>0);
    prediction(idx_word,idx_label) = prediction(idx_word,idx_label) + alpha(m);
end
[~,idx] = max(prediction,[],2);

class = label(idx);