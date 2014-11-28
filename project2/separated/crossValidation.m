function [ est_perr ] = crossvalidation(dataset, C,S)
    % Inputs:
    % - dataset: Training dataset
    % - C:       Hyperparameter for SVM
    % - S:       rbf sigma
    %
    % Output:
    % - est_perr: Estimated prediction error

    % No. of rows in datasets
    [N, Ncols] = size(dataset);

    % No. of training subsets
    K = calculateNSubsets(dataset);

    % No. of rows per training/validation subset
    N_K = floor(N / (K + 1));

    % No. of rows in last subset
    N_L = N - N_K*K;

    % List of prediction errors
    perr_list = [];

    % Pre-allocate T and V subsets
    %T = zeros(N - N_K*K, size(dataset, 1));
    %V = zeros(N_L, size(dataset, 1));

    parameters = zeros(Ncols - 1, 1);

    % For each validation subset
    if isempty(gcp('nocreate'))
        parpool;
    end
    parfor i = 1:K % Position of validation subset

        % Calculate range of rows of validation subset
        i_Vstart = (i-1) * N_K + 1;
        if i < K
                i_Vend = i_Vstart + N_K - 1;
        else
                i_Vend = N;
        end

        % Training data subset
        T = dataset([1:i_Vstart-1 i_Vend+1:N], :);

        % Validation data subset
        V = dataset(i_Vstart:i_Vend, :);

        % Run regression
        %parameters = gradientDescent(T, C, parameters);
        perr = trainInCV(T, V, C,S);

        % Calculate prediction error
        %perr = predictionE(parameters, V);
        perr_list = [perr_list perr];

        %fprintf('%d ', i);
    end
    %fprintf('\n');

    % Calculate estimate of prediction error
    est_perr = mean(perr_list)+2*var(perr_list);
end

function [K] = calculateNSubsets(dataset)
    % Engineers' solution to finding no. of training subsets
    K = min(floor(sqrt(size(dataset, 1))), 30);
    %K = floor(sqrt(size(dataset, 1)));
end
