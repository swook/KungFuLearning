clear all;

T = importData('training.csv');

M = 3;
N = 5;

X = T(:, 1:end-1);
Y = T(:, end);
[Nrows, Ncols] = size(X);

colTitles = {'\beta_0', 'Width', 'ROB size', 'IQ size', 'LSQ size',...
	'RF sizes', 'RF read ports', 'RF write ports', 'Gshare size',...
       	'BTB size', 'Branches allowed', 'L1 lcache size', 'L1 Dcache size',...
	'L2 Ucache size', 'Depth'};

for i = 1:Ncols
	subplot(M, N, i);
	plot(X(:, i), Y, '*');
	title(colTitles(i));
end

savePlot('ResultVsFeatures');

