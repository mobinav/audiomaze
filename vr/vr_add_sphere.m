
function ballTransformNode = vr_add_sphere(myworld, position, radius, diffuseColor)
% ballTransformNode = vr_add_sphere(myworld, position, radius)
% adds an sphere to myworld vrm world and returns its transform

if nargin < 4
    diffuseColor = [0.9 0.6 0.6];
end;

persistent counter

if isempty(counter)
    counter = 0;
end;

counter = counter + 1;

idString = num2str(counter);

ballTransformNode = vrnode(myworld, ['ball_transform' idString],'Transform');

newShape = vrnode(ballTransformNode, 'children', ['ball_Shape' idString] , 'Shape');

newAppear = vrnode(newShape, 'appearance', ['ball_Appearance' idString], 'Appearance');
newMat = vrnode(newAppear, 'material', ['ball_Material' idString],'Material');
% assign properties for the material field
newMat.ambientIntensity = 0.25;
newMat.diffuseColor = diffuseColor;
newMat.shininess = 0.078125;
newMat.specularColor = [0.0955906 0.0955906 0.0955906];

newBox = vrnode(newShape, 'geometry', ['ball_geo' idString],'Sphere');

newBox.radius =radius;

ballTransformNode.translation = position;