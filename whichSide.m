% determine if one point is on one side or the other of a line segment
% params :
%         P : point to test agains
%         A, B : points spanning line segment

function [sign] = whichSide(P, A, B)

    sign = 1;
    if (B(1) - A(1)) * (P(2) - B(2)) - (B(2) - A(2))* (P(1) - B(1)) <=0
        sign = -1;
    end
end

