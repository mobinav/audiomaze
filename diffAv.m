

function [y] = diffAv(x);
persistent xhist
if isempty(xhist)
    xhist = zeros(11,1);
end


y = .1*x - .1*xhist(end);

for n=2:11
    xhist(13-n) = xhist(12-n);
end
xhist(1) = x;
end