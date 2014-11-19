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

        fprintf('Checking for C in %f ~ %f\n', C0, CN);
        for C = Cs
            fprintf('> C   = %f\t\t| ', C);
            errs = [errs crossValidation(T, C)];
            fprintf('  err = %f\n', errs(end));
        end
        fprintf('\n');

        % Select C with smallest estimated prediction errors
        [min_value, min_index] = min(errs);
        selected_C = Cs(min_index);

        C0 = max(selected_C - dC, 1e-7);
        CN = selected_C + dC;
    end

end
