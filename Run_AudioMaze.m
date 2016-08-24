%% notes
% token orientation is messed up -- fixed: path problem in max patch
%% startup the maze
% run this after setting up phasespace, lsl, and sound engine
% clear('mr');
% global mr;
cd('Z:\audiomaze-2.0')
current_dir = pwd;
addpath(current_dir,path);
addpath(strcat(current_dir,'\vr'));
global X;
n_rows = 5;
n_cols = 5;
% room dimensions
w = 6;
h = 6.5;

% make a randomly seeded maze:
random_seed = 10
% [~, mz_lns] = make_maze_polygons(n_rows, n_cols, 'S', 0, random_seed);
% mz_lns = importdata('./mazes/single_corridor.mat');
% mz_lns = importdata('./mazes/scott_testmaze.mat');
mz_lns = makeSimpleMazeRev('E');

% make a prescribed maze (see testMazeBuilder for details)
% maze_c = [0,1; 1,0; 0,0; 0,0; 1,1; 0,0; 0,0; 0,0; 0,0];
% [mz_poly, mz_lns] = make_maze_polygons_nr(n_rows, n_cols,0, maze_c(:,1), maze_c(:,2));

X = maze_init(mz_lns, n_rows, n_cols, h, w, false); 

% physical location of the token speakers
%              
% speaker 5 
speakerLocs = [1,4;2,2;2,5;4,1; 4,4;5,2]; % number corresponds to maze panel: r, c
%speakerLocs = [1,4; 4,4];
tokenMap = [1,1;2,2;3,3;4,4;5,5;6,6];
% % create the tokens object
X.tokens = mazeTokens(X.am, speakerLocs, tokenMap);

% plot(mr.tokens.endpoints(1,1),mr.tokens.endpoints(1,2),'.','tag','markers','markersize',20)
% plot(mr.tokens.endpoints(2,1),mr.tokens.endpoints(2,2),'r.','tag','markers','markersize',20)
% plot(mr.tokens.mocapLocs(1,1),mr.tokens.mocapLocs(1,2),'g.','tag','markers','markersize',20)
% % % specify location of cat and dog 
% % speaker 3 is token 1 (cat), 5 is 2 (different cat)

% mr.tokens.wired
% mr.tokens.active
for n=1:length(tokenMap)+2
    X.tokens.active(n) = 1;
end
% mr.tokens.active

%% start/restart maze
maze_main_loop;    

 %% stop and clear maze
X=stop_maze(X);
pause(2);
close(X.am.fig_handle);
clear('X');


%% stop maze
X=stop_maze(X);
pause(2);

%% clear maze
close(X.am.fig_handle);
clear('X');

%% step through
%X = maze_accumulate_lsl(X); X = maze_show_mocap(X); X = maze_lsl(X);
maze_accumulate_lsl;maze_show_mocap;maze_lsl;

    

