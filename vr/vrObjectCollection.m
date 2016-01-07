classdef vrObjectCollection;
    properties
        object = {};
        objectCalibrationLog = []; % a structure that contains calibration points and type of object as a log. It is used to re-create objects calibrated in one session (for a certain vr world)  to another session (world)
    end % properties
    methods
        function obj = addObjectFromCalibration(obj, vrObjectType, calibrationPoints, vrObjectLabel, world)
            newObject = eval(vrObjectType);
            newObject = newObject.createFromPoints(calibrationPoints, world);
            newObject.label = vrObjectLabel;
            obj = add(obj, newObject);
            
            % save these for future executions, when world variabe might
            % have changed
            obj.objectCalibrationLog(end+1).vrObjectType = vrObjectType;
            obj.objectCalibrationLog(end).calibrationPoints = calibrationPoints;
            obj.objectCalibrationLog(end).vrObjectLabel = vrObjectLabel;
        end;
        function obj = recreateObjectsFromCalibrationLog(obj, world) % recreate previously calibrated objects, useful when adding them to a new world
            obj.object = {};
            for i=1:length(obj.objectCalibrationLog)
                newObject = eval(obj.objectCalibrationLog(i).vrObjectType);
                newObject = newObject.createFromPoints(obj.objectCalibrationLog(i).calibrationPoints, world);
                newObject.label = obj.objectCalibrationLog(i).vrObjectLabel;
                obj = add(obj, newObject);
            end;
        end;
        function [closestDistance closestObject closestPointId distanceToObjects]= distanceTo(obj, point)
            distanceToObjects = inf(length(obj.object), size(point,1));
            
            for i=1:length(obj.object)
                % distanceToObjects is object x point
                distanceToObjects(i,:) = obj.object{i}.distanceTo(point);
            end;
            
            closestDistance = min(distanceToObjects(:));
            [closestObjectId closestPointId] = find(distanceToObjects == closestDistance);
            
            % report only one object, if several with the same distance
            % found
            closestObjectId = closestObjectId(1);
            closestPointId = closestPointId(1);
            
            %  [closestDistance closestObjectId] = min(distanceToObjects);
            closestObject = obj.object{closestObjectId};
        end; % distance from a point to the prism
        function obj = add(obj, newObject)
            obj.object{end+1} = newObject;
        end
        function [closestContactPoint closestContactDistance isPointedTo contactPoint contactDistance contactPolygons] = is_pointed_to_from(obj, point, vector)
            isPointedTo = nan(1, length(obj.object));
            contactPoint = {};
            contactDistance = nan(1, length(obj.object));
            contactPolygons = {};
            
            for i=1:length(obj.object)
                [isPointedTo(i) contactPoint{i} contactDistance(i) contactPolygons{i}] = obj.object{i}.is_pointed_to_from(point, vector);
            end;
            
            % find closest contact (projection) point and its distance from
            % all objects
            closestContactPoint = [];
            closestContactDistance = Inf;
            pointedToIds = find(isPointedTo);
            if ~isempty(pointedToIds)
                [closestContactDistance id]= min(contactDistance(pointedToIds));
                closestContactPoint = contactPoint{pointedToIds(id)};
            end;
        end;
    end; % methods
end