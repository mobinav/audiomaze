function angle = ji_vecang(a,b)
% vecang  compute angle between two vectors
%
%   angle = vecang(a,b)
%
% JRI

angle = acos(dot(a,b)/(norm(a)*norm(b)));