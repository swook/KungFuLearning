%function model = train(X, Y, Cval, Sval)
    % TODO: fitensemble
	clc
	disp('Preprocessing...');
    [D, fpath] = parseCSV('training.csv');	% store input as cell matrix	
    [wordToIdxMap, equivWordMap] = createMaps(D, fpath);
	% get feature words and word Maps 
    X = dictToFeatMat(D, wordToIdxMap, equivWordMap);
    Y = [D{:, 2}]';
	% matrix without repetitions (same input after preprocessing and same output)
	M = unique([X,Y],'rows');
	numZIPcodes=numel(unique(Y));
	disp('End of Preprocessing.');
    fprintf(['# of initial inputs we have to classify : %d\n',...
	'# of inputs we have to classify now : %d\n',...
	'# of feature words : %d\n',...
	'# of different ZIP codes : %d\n']...
	 ,size(X,1), size(M,1), size(X,2),numZIPcodes);

    % Machine Learning (Adaboost?)

    % For Validation Set
    %[V, fpath] = parseCSV('validation.csv');
    %X = dictToFeatMat(V, wordToIdxMap, equivWordMap);
%end
