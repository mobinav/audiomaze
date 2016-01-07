function textOuterTransformNode = vr_add_text_billboard(myworld, position, textString, scale)
% textOuterTransformNode = vr_add_text_billboard(myworld,
% position, textString, scale)

persistent counter

if isempty(counter)
    counter = 0;
end;

if nargin<4
    scale = 0.3;
end;

counter = counter + 1;

idString = num2str(counter);

textOuterTransformNode = vrnode(myworld,['text_outer_transform' idString],'Transform');
textBillBoardNode = vrnode(textOuterTransformNode,'children', ['text_Billboard' idString],'Billboard');

% make the billboard face the viewer at all timesS
textBillBoardNode.axisOfRotation = [0 0 0];
textTransformNode = vrnode(textBillBoardNode, 'children',['text_transform' idString],'Transform');
newShape = vrnode(textTransformNode, 'children', ['text_Shape' idString] , 'Shape');

newAppear = vrnode(newShape, 'appearance', ['text_Appearance' idString], 'Appearance');
newMat = vrnode(newAppear, 'material', ['text_Material' idString],'Material');
% assign properties for the material field
newMat.ambientIntensity = 0.25;
newMat.diffuseColor = [1 1 1];
newMat.shininess = 0.078125;
newMat.specularColor = [0.0955906 0.0955906 0.0955906];

newText = vrnode(newShape, 'geometry', ['text_geo' idString],'Text');

newText.string = textString;
textTransformNode.scale= [scale scale scale];
textTransformNode.translation = [0 0 0];
textOuterTransformNode.translation = position;
