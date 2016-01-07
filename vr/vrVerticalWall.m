classdef vrVerticalWall < vrBox; % a vertical wall in virtual reality
    properties (SetAccess = protected)
        x
        y
        wallHeight
        wallThickness
        isThinWall
    end % properties
    methods
        function obj = vrVerticalWall(world, x, y, wallHeight, wallThickness, isThinWall)
            %obj = vrVerticalWall(world, x, y, wallHeight, wallThickness, isThinWall)
            %
            % creates a vertical wall in virtual reality.
            % isThinWall control is the wall is represented by a prism
            % (default) or it is considered very 'thin' and modeled by only
            % one vertical polygon, which is 6 times faster to calculate
            % distances to.
            % x and y each have two values [x1 x2] and [y1 y2] and define a
            % line from point1 to point2 on which the vertical wall is
            % placed.
            
            wallLength = ((x(2) - x(1)) ^ 2 + (y(2) - y(1)) ^ 2) ^0.5;
            wallCenter = [mean(x) mean(y) wallHeight/2];
            xAngle = atan2 ((y(2) - y(1)) ,  (x(2) - x(1)));

            center = wallCenter;
            dimension = [wallLength wallThickness wallHeight];
            axisAngleRotation = [0 0 1 xAngle];
            
            obj = obj@vrBox(world, center, dimension, axisAngleRotation); % class the super class constructor
            
            % assume walls have no thickness to speed-up distance calculation (uses one polygon instead of all all 6 faces) 
            if nargin>5 && isThinWall
                obj.prism.extensionVector = [0 0 0];
            end;
            
            obj.axisAngleRotation = axisAngleRotation;
            obj.center = center;
            obj.dimension = dimension;
            
            obj.x = x;
            obj.y = y;
            obj.wallHeight = wallHeight;
            obj.wallThickness = wallThickness;
            obj.isThinWall = isThinWall;
            
        end; % constructor
        function closestWallPoint = closestPointOnTheWallTo(obj, point)
            % project the point into the wall polygon, this should work
            % most of the times when the point is not close to the edges of
            % the wall
            closestWallPoint = estimate_point_vertical_projection_on_wall(obj, point);
            
        end; % approximates and returns the closest point from the wall to a given point. This currently only assumes 'thin' walls with effectively one polygon 
    end; % methods
end