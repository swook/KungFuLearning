function model = train(X, Y, Cval, Sval)
    % TODO: fitensemble
    [D, fpath] = parseCSV('training.csv');
    [wordToIdxMap, equivWordMap] = createMaps(D, fpath);
    X = dictToFeatMat(D, wordToIdxMap, equivWordMap);
    Y = [D{:, 2}]';

    % Machine Learning (Adaboost?)

    % For Validation Set
    %[V, fpath] = parseCSV('validation.csv');
    %X = dictToFeatMat(V, wordToIdxMap, equivWordMap);
end
