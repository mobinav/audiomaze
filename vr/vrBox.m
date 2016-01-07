classdef vrBox < vrPrism;
    properties (SetAccess = protected)
        dimension
        center
        axisAngleRotation = [0 0 1 0]; % no rotation by default
    end % properties
    methods
        function obj = vrBox(world, center, dimension, axisAngleRotation)
            % obj = vrBox(world, center, dimension, eulerAngles)
            superClassArgs = {};
            
            if nargin>0
                superClassArgs{1} = world;
            end;
            
            obj = obj@vrPrism(superClassArgs); % class the super class constructor
            
            if nargin>0
                obj.dimension = dimension;
                obj.center = center;
            end;
            
            if nargin>3
                obj.axisAngleRotation = axisAngleRotation;
            end;
            
            if nargin>0
                [obj.transformNode obj.prism] = vr_box(world, obj.center, obj.dimension, obj.axisAngleRotation);
            end;
        end; % constructor
        function obj = createFromPoints(obj, point, world)
            % create a box from actual measurement in 3D (usually for  calibration
            % between vr and actual 3D experiemnt space).
            % First the top of the box is measured is the clockwise order, then the edge on
            % the bottom of the first location is measured as the 5th point.
            % point is 5 x 3 vector containig 5 points.
            
            dimensionVector1 = ((point(2,:)-point(1,:)) + (point(3,:)-point(4,:))) / 2;
            dimensionVector2 = ((point(3,:)-point(2,:)) + (point(4,:)-point(1,:))) / 2;
            dimensionVector3 = point(5,:)-point(1,:);
            
            obj.dimension = [norm(dimensionVector1, 'fro')  norm(dimensionVector2, 'fro') norm(dimensionVector3, 'fro')];
            
            %             obj.eulerAngles(3) = acos(dimensionVector1 * [1 0 0]'/ obj.dimension(1));
            %             obj.eulerAngles(1) = 0*acos(dimensionVector2 * [0 1 0]'/ obj.dimension(2));
            %             obj.eulerAngles(2) = 0*acos(dimensionVector3 * [0 0 1]'/ obj.dimension(3));
            
            
            % note to self: we should use DCM instead and turn it into
            % axis-angle rotation...
            
            
            directionCosineMatrix = cat(2, dimensionVector1' / obj.dimension(1), dimensionVector2' / obj.dimension(2), dimensionVector3' / obj.dimension(3));
            axisAngle = vrrotmat2vec(directionCosineMatrix);
            
            %             obj.eulerAngles(1) = atan2(-dimensionVector3(2), dimensionVector3(1));
            %             obj.eulerAngles(2) = atan2(dimensionVector3(3), sum(dimensionVector3(1:2).^2)^0.5);
            %             obj.eulerAngles(3) = atan2(dimensionVector2(3), dimensionVector1(3));
            %
            obj.center = mean(point(1:4,:), 1) + dimensionVector3 / 2;
            
            if nargin>2 % world parameter is given as input
                obj = vrBox(world, obj.center, obj.dimension, axisAngle);
            end;
        end;
    end; % methods
end