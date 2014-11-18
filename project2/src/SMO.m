function  alpha = SMO( T,C )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    tol=  1e-1;        %numerical tolerance
    maxPasses=10;   %maximum number of Iterations for 1 alpha
    
    Ncol=size(T,1);
    X=T(:,2:end-1);     % X without interceptor
    y=T(:,end);
    alpha=zeros(Ncol,1);
    alpha_old=zeros(Ncol,1);
    b=0;         %threshold
    passes=0;
    E=zeros(Ncol,1);
    f =@(i,b,alpha) sum(((X*X(i,:)').*y).*alpha)+b; 
    eta=@(i,j) 2*X(i,:)*X(j,:)'-X(i,:)*X(i,:)'-X(j,:)*X(j,:)';
    
    while (passes<maxPasses)
        num_changed_alphas=0;
        for i=1:Ncol
            disp(num2str(i))
            E(i)=f(i,b,alpha)-y(i);
            if ((y(i)*E(i)<-tol && alpha(i)<C)|| (y(i)*E(i)>tol && alpha(i)>0))
                j=i;
                while j==i
                    j=randi(Ncol);
                end
                E(j)=f(j,b,alpha)-y(j);
                alpha_old(i)=alpha(i);
                alpha_old(j)=alpha(j);
                if y(i)~=y(j)
                    L=max(0,alpha(j)-alpha(i));
                    H=min(C,C+alpha(j)-alpha(i));
                else 
                    L=max(0,alpha(j)+alpha(i)-C);
                    H=min(C,alpha(j)+alpha(i));
                end
                if L==H
                    continue
                end
                eta_temp=eta(i,j);
                if eta_temp>=0
                    continue
                end
                alpha(j)=alpha(j)-y(j)*(E(i)-E(j))/eta_temp;
                if alpha(j)>H
                    alpha(j)=H;
                elseif alpha(j)<L
                    alpha(j)=L;
                end
                if abs(alpha(j)-alpha_old(j))<1e-5
                    continue
                end
                alpha(i)=alpha(i)+y(i)*y(j)*(alpha_old(j)-alpha(j));
                b1=b-E(i)-y(i)*(alpha(i)-alpha_old(i))*(X(i,:)*X(i,:)')-...
                    y(j)*(alpha(j)-alpha_old(j))*(X(i,:)*X(j,:)');
                b2=b-E(j)-y(i)*(alpha(i)-alpha_old(i))*(X(i,:)*X(j,:)')-...
                    y(j)*(alpha(j)-alpha_old(j))*(X(j,:)*X(j,:)');
                if (0<alpha(i) && alpha(i)<C)
                    b=b1;
                elseif (0<alpha(j) && alpha(j)<C)
                    b=b2;
                else
                    b=(b1+b2)/2;
                end
                num_changed_alphas=num_changed_alphas+1;
            end
        end
        if num_changed_alphas==0
            passes=passes+1;
        else
            passes=0;
        end
    end
end


