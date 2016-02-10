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
% make a randomly seeded maze:
random_seed = 12;
[~, mz_lns] = make_maze_polygons(n_rows, n_cols, 'S', .05, random_seed)


% make a prescribed maze (see testMazeBuilder for details)
% maze_c = [0,1; 1,0; 0,0; 0,0; 1,1; 0,0; 0,0; 0,0; 0,0];
% [mz_poly, mz_lns] = make_maze_polygons_nr(n_rows, n_cols,0, maze_c(:,1), maze_c(:,2));

% note : this could be better designed in terms of i/o and arguments
% maze_init  should call make_maze_polygons_xx so that the user supplies
% merely rows, columns, and a maze representation or random seed
mr = maze_init(mz_lns, n_rows, n_cols, true); 


%% main loop
maze_main_loop;

%% stop maze

stop_maze;
pause(2);
clear all;

%% step through
maze_accumulate_lsl; maze_show_mocap; maze_lsl;



