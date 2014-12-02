function [D, newfpath] = parseCSV(fname)
	% loads csv file with strings into cell Matrix D
	% returns path as well
    fpath = ['../data/', fname];
    newfpath = strrep(fpath, '.csv', '_split.dat');

	% no need to run function again if that file was already loaded
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

    instr = '';
    outstr = '';

    for j = 1:M
        instr = rawD{1}{j};

        % Remove non-alphanumeric characters
        instr = regexprep(instr, '([^ \w]*)', '');

        % Set to lower case
        instr = lower(instr);

        % Trim whitespace at start and end of string
        instr = strtrim(instr);

        % Change into array of words
        outstr = strsplit(instr, ' ');

        D{j, 1} = outstr;
        D{j, 2} = rawD{2}(j);
        D{j, 3} = rawD{3}(j);
    end

    save(newfpath, 'D');
end
