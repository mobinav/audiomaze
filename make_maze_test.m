cd('Z:\audiomaze-2.0')
current_dir = pwd;
addpath(current_dir,path);
addpath(strcat(current_dir,'\vr'));

mr = [];
mr.mocap = [];

w = 6.5;
h = 6.5;

cur_dir = pwd;
vr_path = strcat(cur_dir,'\vr\minimal_with_axis_captions');
mocapWorld = vrworld(vr_path, 'new');
open(mocapWorld);


if~isfield(mr.mocap, 'afterInitCallback')
   mr.mocap.afterInitCallback = '';
end;


mr.mocap.afterInitCallback = 'mr_draw_maze; mr.mocap.roomWallCollection = vr_add_sccn_mobi_room(mr.mocap.mocapWorld);';

% add boundaries of sccn room
% copied from vr_add_sccn_mobi_room.m
roomWallCollection = vrObjectCollection;
roomWidth = w;
roomHeight = h;
roomWallCollection = roomWallCollection.add(vrVerticalWall(mocapWorld, [-roomWidth, -roomWidth]/2, [roomHeight, -roomHeight]/2, 0.3,0.05, true));
roomWallCollection = roomWallCollection.add(vrVerticalWall(mocapWorld, [-roomWidth, roomWidth]/2, [-roomHeight, -roomHeight]/2, 0.3,0.05, true));
roomWallCollection = roomWallCollection.add(vrVerticalWall(mocapWorld, [-roomWidth, roomWidth]/2, [roomHeight, roomHeight]/2, 0.3,0.05, true));
roomWallCollection = roomWallCollection.add(vrVerticalWall(mocapWorld, [roomWidth, roomWidth]/2, [roomHeight, -roomHeight]/2, 0.3,0.05, true));

% extend the geometrical representation of walls to extend from very low to
% very high and cover the whole height of the room
for i=1:4
    roomWallCollection.object{i}.prism.polygon(3, 1:2) = [-10000 -10000];
    roomWallCollection.object{i}.prism.polygon(3, 3:4) = [10000 10000];
end;
mr.mocap.roomWallCollection = roomWallCollection; 
mr.mocap.mocapWorld = mocapWorld;

%%
figureHandle = view(mr.mocap.mocapWorld);
vrdrawnow;

%%
n_rows = 3;
n_cols = 3;
% make a randomly seeded maze:
random_seed = 1;
[mz_poly, mz_lns] = make_maze_polygons(n_rows, n_cols, 'S', .1, random_seed);
mr.am = audioMaze(h, w, n_rows, n_cols, mz_lns, mz_poly);

%% from vr_add_maze
% values are from the original call from mr_maze_with_lsl.m
xScale = 1.5;
yScale = 2;
wallHeight = 2;
wallThickness = .1;

xOffset = mean(mean(mz_lns(:, 1:2))) - 0.15;
yOffset = mean(mean(mz_lns(:, 3:4))) - 0.15;

mazeLinesForVr = mz_lns;
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
for i=1:size(mz_lns,1)
    wallCollection = wallCollection.add(vrVerticalWall(mr.mocap.mocapWorld, mazeLinesForVr(i, 1:2), mazeLinesForVr(i, 3:4) , wallHeight, wallThickness, true));
end;



figureHandle = view(mr.mocap.mocapWorld);
vrdrawnow;







