%% notes
% token orientation is messed up -- fixed: path problem in max patch
%% startup the maze
% run this after setting up phasespace, lsl, and sound engine
clear('mr');
global mr;
cd('Z:\audiomaze-2.0')
current_dir = pwd;
addpath(current_dir,path);
addpath(strcat(current_dir,'\vr'));

n_rows = 5;
n_cols = 5;
% room dimensions
w = 6;
h = 6.5;

% make a randomly seeded maze:
random_seed = 12;
[~, mz_lns] = make_maze_polygons(n_rows, n_cols, 'S', .05, random_seed)


% make a prescribed maze (see testMazeBuilder for details)
% maze_c = [0,1; 1,0; 0,0; 0,0; 1,1; 0,0; 0,0; 0,0; 0,0];
% [mz_poly, mz_lns] = make_maze_polygons_nr(n_rows, n_cols,0, maze_c(:,1), maze_c(:,2));

mr = maze_init(mz_lns, n_rows, n_cols, h, w, false); 

% physical location of the token speakers
%              
% speaker 5 
speakerLocs = [1,4;2,2;2,5;4,1; 4,4;5,2]; % number corresponds to maze panel: r, c
%speakerLocs = [1,4; 4,4];
tokenMap = [1,1;2,2;3,3;4,4;5,5;6,6];
% % create the tokens object
mr.tokens = mazeTokens(mr.am, speakerLocs, tokenMap);

% plot(mr.tokens.endpoints(1,1),mr.tokens.endpoints(1,2),'.','tag','markers','markersize',20)
% plot(mr.tokens.endpoints(2,1),mr.tokens.endpoints(2,2),'r.','tag','markers','markersize',20)
% plot(mr.tokens.mocapLocs(1,1),mr.tokens.mocapLocs(1,2),'g.','tag','markers','markersize',20)
% % % specify location of cat and dog 
% % speaker 3 is token 1 (cat), 5 is 2 (different cat)

% mr.tokens.wired
% mr.tokens.active
for n=1:6
    mr.tokens.active(n) = n
end
% mr.tokens.active

%% main loop
maze_main_loop;

%% stop maze

stop_maze;
pause(2);

clear all;

%% step through
maze_accumulate_lsl; maze_show_mocap; maze_lsl;



