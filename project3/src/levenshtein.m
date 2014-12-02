function [l]= levenshtein(a,b,i,j)
	% Levenshtein distance between two strings a and b
	if nargin<3
		i= length(a);
		j=length(b);
	end
	if min(i,j)==0
		l=max(i,j);
	else
		p=(a(i)~=b(j));
		l=min([levenshtein(a,b,i-1,j)+1,...
			levenshtein(a,b,i,j-1)+1,...
			levenshtein(a,b,i-1,j-1)+p]);
	end
end
