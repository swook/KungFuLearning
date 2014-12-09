function [wordToIdxMap, equivWordMap] = createMaps(D, fname)
	% creates word Maps from cell matrix D which indicate what Words
	% are important (used as feature) and where they are found in D.
	% equivWordMap: insignificantWord -> featureWord
    % wordToIdxMap: featureWord       -> Col. index in X

    fpath = ['../data/', fname];

    wordToIdxMap = containers.Map();
    equivWordMap = containers.Map();

    if ~exist(fpath)
        disp('Wrong input file');
        return;
    end

    [M, N] = size(D);

    % Create initial dictionary of all words
    newfpath = strrep(fpath, '_split.dat', '_dict.dat');
    if exist(newfpath)
        dat = load(newfpath, 'dict', '-mat');
        dict = dat.dict;
    else
        word = '';
        dict = containers.Map();
        for j = 1:M
            for c = 1:length(D{j, 1})
                word = char(D{j, 1}(c));

                % Ignore empty-string
                if length(word) == 0
                    continue;
                end

                % Set value to 0 if new key
                if ~isKey(dict, word)
                    dict(word) = 0;
                end
                dict(word) = dict(word) + 1;
            end
        end

        save(newfpath, 'dict');
    end

    % Reduce dictionary by reducing duplicates
    newfpath = strrep(fpath, '_split.dat', '_dict_reduced.dat');
    if exist(newfpath)
        dat = load(newfpath, 'equivWordMap', 'wordToIdxMap', '-mat');
        equivWordMap = dat.equivWordMap;
        wordToIdxMap = dat.wordToIdxMap;
    else
        % NOTE: following are cell arrays
        words  = dict.keys;
        counts = dict.values;
        N = length(dict.keys);

        % 1. Sort in descending occurrence count
        [~, indices] = sort(cell2mat(counts));
        indices = flip(indices);

        idx1 = 0;
        idx2 = 0;
        word1 = '';
        word2 = '';
        count1 = 0;
        count2 = 0;
        threshold = 0.2; % Proportion value

        % 2. Go down words list (word1) and check all other words below (word2)
        for i = 1:N
            idx1   = indices(i);
            word1  = words{idx1};
            count1 = counts{idx1};
            len1   = length(word1);

            % If considered as insignificantWord before (won't be in dict anymore)
            if ~isKey(dict, word1)
                continue;
            end

            fprintf('%d) %s: %d\n' , i, word1, count1);
            for j = max(i+1, 500):N % Top 30 words aren't insignificant. Valid features.
                idx2   = indices(j);
                word2  = words{idx2};
                count2 = counts{idx2};
                len2   = length(word2);

                % If considered as insignificantWord before (won't be in dict anymore)
                if ~isKey(dict, word2)
                    continue;
                end

                thresh = max(1, threshold * max(len1, len2));
                if abs(len1-len2) > thresh
                    continue;
                end

                dist = levenshtein(thresh, word1, word2);

                % - if levenshtein(word1, word2) lower than threshold
                %   NOTE: threshold is proportion of max(length(word1), length(word2))
                %     equivWordMap(word2) = word1;
                if dist <= thresh
                    equivWordMap(word2) = word1;
                    remove(dict, word2);
                    %fprintf('- %s is similar to %s\n', word1, word2);
                end
                % - else
                %     continue;

            end
        end

        % Create wordToIdxMap, a map from word to index on feature matrix
        keys = dict.keys;
        for i = 1:dict.Count
            wordToIdxMap(keys{i}) = i;
        end

        save(newfpath, 'equivWordMap', 'wordToIdxMap');
    end
end
