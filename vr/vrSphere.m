classdef vrSphere < vrObject;
    properties
        radius
        center
        filled
    end % properties
    methods
        function d = distanceTo(obj, point)
            d = norm(obj.transformNode.translation - point, 'fro') - obj.radius;
            
            if obj.filled && d<0 % if the sphere is filled and the point is inside, distance is set to zero
                d = 0;
            end;
            
        end; % distance from a point to the box
        function obj = vrSphere(world, center, radius, filled, varargin)
            superClassArgs = {};
            
            if nargin>0
                superClassArgs{1} = world;
            end;
            
            obj = obj@vrObject(superClassArgs); % class the super class constructor
            if nargin>0
                obj.radius = radius;
                obj.center = center;
                obj.transformNode = vr_add_sphere(world, center, radius, varargin{:});
            end;
            
            if nargin>3
                obj.filled = filled;
            else
                obj.filled = true;
            end;
        end; % constructor
        function obj = createFromPoints(obj, point, world)
            % create a sphere from actual measurement in 3D (usually for  calibration
            % between vr and actual 3D experiemnt space).
            % point is 2 x 3 vector containig 2 points on two opposite (across diameter) of the sphere.
            
            obj.radius = norm(point(2,:) - point(1,:), 'fro') / 2;
            obj.center = mean(point, 1);
            obj.transformNode = vr_add_sphere(world, obj.center, obj.radius);
            
        end;
    end; % methods
end