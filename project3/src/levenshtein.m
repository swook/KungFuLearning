function dist = levenshtein(thresh, str1, str2)
    L1=length(str1)+1;
    L2=length(str2)+1;
    L=zeros(L1,L2);

    g=+1;%just constant
    m=+0;%match is cheaper, we seek to minimize
    d=+1;%not-a-match is more costly.

    %do BC's
    L(:,1)=([0:L1-1]*g)';
    L(1,:)=[0:L2-1]*g;

    m4=0;%loop invariant
    for idx=2:L1;
        for idy=2:L2
            if(str1(idx-1)==str2(idy-1))
                score=m;
            else
                score=d;
            end
            m1=L(idx-1,idy-1) + score;
            m2=L(idx-1,idy) + g;
            m3=L(idx,idy-1) + g;
            L(idx,idy)=min(m1,min(m2,m3));

            if L(L1,L2) > thresh
                dist = L(L1, L2);
                return;
            end
        end
    end

    dist=L(L1,L2);
    return;
end
%function [l]= levenshtein(a,b,i,j)
%	% Levenshtein distance between two strings a and b
%	if nargin<3
%		i= length(a);
%		j=length(b);
%	end
%	if min(i,j)==0
%		l=max(i,j);
%	else
%		p=(a(i)~=b(j));
%		l=min([levenshtein(a,b,i-1,j)+1,...
%			levenshtein(a,b,i,j-1)+1,...
%			levenshtein(a,b,i-1,j-1)+p]);
%	end
%end
