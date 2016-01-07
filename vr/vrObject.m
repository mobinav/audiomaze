classdef vrObject
    properties
        transformNode % the outer transform vr node of the object
        label % text information, like name or a more detailed description of what the object is, this is useful when objects are in an array, for example in vrCollection and you want to know what is the object
    end % properties
    properties (SetAccess = protected)
        world   % vr World object
    end;
    methods
        function obj = vrObject(world)
            if nargin>0
                obj.world = world;
            end;
        end;
    end;
    methods (Abstract)
        distanceTo;
    end;
end