function X = dictToFeatMat(D, wordToIdxMap, equivWordMap)
    % equivWordMap: insignificantWord -> featureWord
    % wordToIdxMap: featureWord       -> Col. index in X

    M = size(D, 1);
    N = wordToIdxMap.Count;
    words = wordToIdxMap.keys;

    X = zeros(M, N);	% feature Matrix for classification

    word = '';
    idx  = 0;
    for j = 1:M
        % Go through each word
        for c = 1:length(D{j, 1})
            word = char(D{j, 1}(c));

            % If there is word mapping
            if equivWordMap.isKey(word)
                word = equivWordMap(word);
            end

            % TODO: If word doesn't exist in wordToIdxMap, expand equivWordMap
            %       to include word->{existing featureWord}
            if ~wordToIdxMap.isKey(word)
                dists = zeros(N, 1);
                for w = 1:N
                    dists(w) = levenshtein(3, word, words{w});
                end
                [~, I] = min(dists);
                word = words{I};
            end

            % Increment occurrence count of word in sentence
            idx = wordToIdxMap(word);
            X(j, idx) = X(j, idx) + 1;
        end
    end
end
