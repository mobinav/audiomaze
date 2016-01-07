function wallCollection = vr_add_maze(myworld, xScale, yScale, wallHeight, wallThickness, mazeRandomSeed)
% wallCollection = vr_add_maze(myworld, scale, wallHeight, wallThickness, mazeRandomSeed)
% make maze in 3d with walls
if nargin<2
    scale = 200;
end;

if nargin<4
    wallHeight = 200;
end;

if nargin<5
    wallThickness = 2;
end;



wallThicknessForSmallScale = 0.05;

if nargin<6
    [mazePolygons mazeLines]  = make_maze_polygons(4,4,'S', wallThicknessForSmallScale);
else
    [mazePolygons mazeLines]  = make_maze_polygons(4,4,'S', wallThicknessForSmallScale, mazeRandomSeed);
end;



%[mazePolygons mazeLines]  = make_maze_polygons(5,5,'S', wallThicknessForSmallScale);

% center the maze
xOffset = mean(mean(mazeLines(:, 1:2))) - 0.15;
yOffset = mean(mean(mazeLines(:, 3:4))) - 0.15;

mazeLinesForVr = mazeLines;
mazeLinesForVr(:,1:2) = mazeLinesForVr(:,1:2) - xOffset;
mazeLinesForVr(:,3:4) = mazeLinesForVr(:,3:4) - yOffset;

% scale the maze
%mazeLinesForVr = mazeLinesForVr * scale;
mazeLinesForVr(:,1:2) = mazeLinesForVr(:,1:2) * xScale;
mazeLinesForVr(:,3:4) = mazeLinesForVr(:,3:4) * yScale;

% scale ground box
% mazeXextent = max(max(mazeLinesForVr(:, 1:2))) - min(min(mazeLinesForVr(:, 1:2)));
% mazeYextent = max(max(mazeLinesForVr(:, 3:4))) - min(min(mazeLinesForVr(:, 3:4)));
% myworld.ground_box.size = [mazeXextent mazeYextent 5];

wallCollection = vrObjectCollection;
for i=1:size(mazeLines,1)
  wallCollection = wallCollection.add(vrVerticalWall(myworld, mazeLinesForVr(i, 1:2), mazeLinesForVr(i, 3:4) , wallHeight, wallThickness, true));
end;
