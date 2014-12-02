function [dict, newfpath] = createDict(D, fname)
    fpath = ['../data/', fname];
    newfpath = strrep(fpath, '_split.dat', '_dict.dat');

    if exist(newfpath)
        dat = load(newfpath, 'dict', '-mat');
        dict = dat.dict;
        return;
    end

    if ~exist(fpath)
        disp('Wrong input file');
        return;
    end

    [M, N] = size(D);

    % Create dictionary of all words
    word = '';
    dict = containers.Map();
    for j = 1:M
        for c = 1:length(D{j, 1})
            word = char(D{j, 1}(c));
            if ~isKey(dict, word)
                dict(word) = 0;
            end
            dict(word) = dict(word) + 1;
        end
    end

    save(newfpath, 'dict');
end
