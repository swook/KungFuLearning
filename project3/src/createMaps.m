function [wordToIdxMap, equivWordMap] = createMaps(D, fname)
    fpath = ['../data/', fname];

    wordToIdxMap = containers.Map();
    equivWordMap = containers.Map();

    if ~exist(fpath)
        disp('Wrong input file');
        return;
    end

    % Create initial dictionary of all words
    newfpath = strrep(fpath, '_split.dat', '_dict.dat');
    if exist(newfpath)
        dat = load(newfpath, 'dict', '-mat');
        dict = dat.dict;
    else

        [M, N] = size(D);

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
        dat = load(newfpath, 'dict', '-mat');
        dict = dat.dict;
    else
        % save(newfpath, 'dict');
    end

    % Create wordToIdxMap, a map from word to index on feature matrix
    keys = dict.keys;
    for i = 1:dict.Count
        wordToIdxMap(keys{i}) = i;
    end
end
