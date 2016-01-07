function [boxTransformNode boxPrism]= vr_box(world, center, dimension, axisAngleRotation, baseName)

if nargin<4
    axisAngleRotation = [0 0 1 0];
end;

if nargin<5
    baseName = 'box_';
end;

name = vr_new_name_based_on(world, baseName);

boxTransformNode = vrnode(world, [name '_box_transform' ], 'Transform');

newShape = vrnode(boxTransformNode, 'children', [name '_box_Shape' ] , 'Shape');

newAppear = vrnode(newShape, 'appearance', [name '_box_Appearance' ], 'Appearance');
newMat = vrnode(newAppear, 'material', [name '_box_Material' ],'Material');
% assign properties for the material field
newMat.ambientIntensity = 0.25;
newMat.diffuseColor = [0.9 0.6 0.6];
newMat.shininess = 0.078125;
newMat.specularColor = [0.0955906 0.0955906 0.0955906];

newBox = vrnode(newShape, 'geometry', [name '_box_geo' ],'Box');

newBox.size = dimension;

boxTransformNode.translation = center;
boxTransformNode.rotation = axisAngleRotation;
%% create the prism structure (a polygon and an extension vector) for the box
halDimension = dimension / 2;

boxPolygon =  [-halDimension(1) -halDimension(2) -halDimension(3);...
                halDimension(1) -halDimension(2) -halDimension(3);... 
                halDimension(1) -halDimension(2) halDimension(3);...
                -halDimension(1) -halDimension(2) halDimension(3)]';
            
extensionVector = [ 0 dimension(2) 0]';

finalRotationMatrix = vrrotvec2mat(boxTransformNode.rotation);
rotatedBoxPolygon = finalRotationMatrix * boxPolygon;
rotatedExtensionVector = finalRotationMatrix * extensionVector;

% we should translate after rotation (not vice versa)
rotatedBoxPolygon = rotatedBoxPolygon + repmat(center', 1,4); % move to center location

% place them in proper 'prism' format, used by distanceToPrism() function.
boxPrism.polygon = rotatedBoxPolygon;
boxPrism.extensionVector = rotatedExtensionVector';
