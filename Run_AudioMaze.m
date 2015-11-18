%% startup the maze
% run this after setting up phasespace, lsl, and sound engine
cd('Z:\audiomaze-2.0')
current_dir = pwd;
addpath(current_dir,path);
maze_init;

%% main loop
maze_main_loop;

%% stop maze

stop_maze;
pause(2);
clear all;

%% step through
maze_accumulate_lsl; maze_show_mocap; maze_lsl;



