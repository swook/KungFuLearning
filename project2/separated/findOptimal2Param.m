function [Aopt,Bopt]=findOptimal2Param(T,Amin,Amax,Bmin,Bmax)
    N=5;        %Number of grid points is N^2
    tol=1e-4;   
    derr=1e3;   %Starting values
    oldAopt=1;
    oldBopt=2;
    errs = ones(N,N);    %initialize error vector
    while derr > tol
        
        Av=linspace(Amin,Amax,N);   %linear grid
        Bv=linspace(Bmin,Bmax,N);
        dA=Av(2)-Av(1);
        dB=Bv(2)-Bv(1);
        i=1;
       
        fprintf('Checking in C:%f ~ %f, S:%f ~ %f\n', Amin, Amax, Bmin, Bmax);
        for A=Av  %loop over first parameter values
            fprintf('C = %f\n ',A);
             j=1;
            for B=Bv %loop over second parameter values
                fprintf('\t S = %f\t\t| ',B);
                errs(i,j) = crossValidation(T,A,B);
                fprintf('\t err=%f\n',errs(i,j)) 
                j=j+1;
            end
            i=i+1;
        end

        % Select V with smallest estimated prediction errors
%         [minErr,idx] = min(errs(:));
%         [idxA,idxB] = ind2sub(size(errs),idx);
        err=errs
        [iA,iB] = find(errs==min(errs(:)));
        idxA=iA(ceil(end/2));
        idxB=iB(ceil(end/2));
        minErr=errs(idxA,idxB);
        Aopt = Av(idxA);
        Bopt = Bv(idxB);
        
        fprintf('  minErr = %.15f,\t Copt = %.4f,\t Sopt = %.4f\n', minErr, Aopt,Bopt);
        if idxA<N
            if idxB<N
                derr=max(abs(minErr-errs(idxA,idxB+1)),abs(minErr-errs(idxA+1,idxB)));
            else
                derr=max(abs(minErr-errs(idxA,idxB-1)),abs(minErr-errs(idxA+1,idxB)));
            end
        else
            if idxB<N
                derr=max(abs(minErr-errs(idxA,idxB+1)),abs(minErr-errs(idxA-1,idxB)));
            else 
                derr=max(abs(minErr-errs(idxA,idxB-1)),abs(minErr-errs(idxA-1,idxB)));
            end
        end
        if (Aopt==oldAopt && Bopt==oldBopt && derr<1e-2)
            break
        end
        Amin = max(Aopt - dA, 1e-4);
        Amax = Aopt + dA;
        Bmin = max(Bopt - dB, 1e-4);
        Bmax = Bopt + dB;
        oldAopt=Aopt;
        oldBopt=Bopt;
        
        
    end

end


