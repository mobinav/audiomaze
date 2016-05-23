function [angle] = findAngularDistance(x,y,varargin)

% find the angular distance between 2 vectors
% In:
%   x: a vector
%   y: a vector
%
%   Options:
%           'degrees' : return angle in degrees instead of radians
%           putting anything here will return the answer in degrees
%           the default is to return radians
    
    num = dot(x,y);
    denom = norm(x)*norm(y);
    angle = acos(num/denom);
    if(nargin>2)    
        angle = 360*angle/2/pi;
    end
end