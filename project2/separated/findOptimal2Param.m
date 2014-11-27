function [Aopt,Bopt]=findOptimal2Param(T,Amin,Amax,Bmin,Bmax)
    N=5;        %Number of grid points is N^2
    tol=1e-4;
    derr=1e3;
    while derr > tol
        
        Av=linspace(Amin,Amax,N);
        Bv=linspace(Bmin,Bmax,N);
        dA=Av(2)-Av(1);
        dB=Bv(2)-Bv(1);
        errs = ones(N,N);
        i=1;
       
        fprintf('Checking in C:%f ~ %f, S:%f ~ %f\n', Amin, Amax, Bmin, Bmax);
        for A=Av
            fprintf('C = %f\t\t|\n ',A);
             j=1;
            for B=Bv
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
        
        Amin = max(Aopt - dA, 1e-4);
        Amax = Aopt + dA;
        Bmin = max(Bopt - dB, 1e-4);
        Bmax = Bopt + dB;
        
        
    end

end


