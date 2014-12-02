function [D, newfpath] = parseCSV(fname)
    fpath = ['../data/', fname];
    newfpath = strrep(fpath, '.csv', '_split.dat');

    if exist(newfpath)
        dat = load(newfpath, 'D', '-mat');
        D = dat.D;
        return;
    end

    if ~exist(fpath)
        disp('Wrong input file');
        return;
    end

    fid = fopen(fpath);
    rawD = textscan(fid, '%s %n %n', 'Delimiter', ',', 'Whitespace', '');
    fclose(fid);

    N = size(rawD, 2);
    M = size(rawD{1}, 1);
    D = cell(M, N);

    for j = 1:M
        D{j, 1} = strsplit(lower(rawD{1}{j}));
        D{j, 2} = rawD{2}(j);
        D{j, 3} = rawD{3}(j);
    end

    save(newfpath, 'D');
end
