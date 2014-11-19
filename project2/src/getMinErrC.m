function selected_C = getMinErrC(T)
    % Minimum step in searching for min-err-C
    CN = 100;
    dC = CN;
    min_dC = .1;
    C0 = min_dC;

    % Reduce range in which to search for value of C at minimum
    % estimated prediction error
    while dC > min_dC
        dC = (CN - C0) / 10;
        Cs = C0:dC:CN;

        errs = [];

        disp(['Checking for C in ', num2str(C0), ' ~ ', num2str(CN)]);
        for C = Cs
            disp(sprintf('C = %f\t|\t', C));
            errs = [errs crossValidation(T, C)];
            disp(sprintf('\t|\terr = %f', errs(end)));
        end

        % Select C with smallest estimated prediction errors
        [min_value, min_index] = min(errs);
        selected_C = Cs(min_index);

        C0 = max(selected_C - dC, 1e-7);
        CN = selected_C + dC;
    end

end
