classdef vrPrism < vrObject;
    properties
        prism
        isFilled = true;
    end % properties
    methods
        function [isPointedTo contactPoint contactDistance contactPolygons] = is_pointed_to_from(obj, point, vector)
            % [isPointedTo contactPoint contactDistance contactPolygons] = is_pointed_to_from(obj, point, vector)
            % returns a boolean value and other values indicating whether a
            % point projected along vector will 'hit' the prism.
            % sorted contact points (from closest to furthest), their distances and contacted polygons are also returned.
            % 
            % point is 1 x 3, vector is 1 x 3
            
            [contactPoint contactDistance contactPolygons] = project_point_to_prism(point, vector, obj.prism.polygon, obj.prism.extensionVector);
            isPointedTo = ~isempty(contactPoint);
        end;
        function d = distanceTo(obj, point)
            d = distance_to_prism(point, obj.prism.polygon, obj.prism.extensionVector, true);
        end; % distance from a (or a group of) point to the prism
        function obj = vrPrism(world)
            superClassArgs = {};
            
            if nargin>0
                superClassArgs{1} = world;
            end;
            
            obj = obj@vrObject(superClassArgs); % class the super class constructor
        end; % constructor
    end; % methods
end