function [TF] = doesIntersect(A,B,C,D)

    TF = true;
    
    sign1 = whichSide(A, C,D);
    sign2 = whichSide(B, C,D);
    if sign1 == sign2
        TF = false;
    end
    
    if TF
        sign1 = whichSide(C, A,B);
        sign2 = whichSide(D, A,B);
        if sign1 == sign2
            TF = false;
        end
    end
    
    
end