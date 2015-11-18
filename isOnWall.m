% determine if one point is on a line (wall in audio maze)
% params :
%         P : point to test agains
%         A, B : points spanning line segment

function [TF] = isOnWall(P, A, B)

    TF = false;
    if (B(1) - A(1))*(P(2) - B(2)) - (B(2) - A(2))* (P(1) - B(1)) ==0
        TF = true;
    end
end

