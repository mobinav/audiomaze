
%% setup
% set path correctly
cd('Z:\audiomaze-2.0')
current_dir = pwd;
addpath(current_dir,path);
addpath(strcat(current_dir,'\vr'));

% global 'everything' variable
global X;

% maze dimensions
n_rows = 5;
n_cols = 5;

% room dimensions
w = 6;
h = 6.5;

% choose a simple maze to run
mz_lns = makeSimpleMazeRev('E');

% initialize the X variable
% this function does the following
% 1. initializes all the variables in the structure
% 2. makes the maze by calling the audioMaze constructor (audioMaze.m)
% 3. concocts the VR representation if the last argument is 'true'
% 4. sets up all the LSL outlets
% 5. sets up the LSL inlet (looks for pahsespace stream) and defines the
% phasespace markers of interest (head and hand markers)
X = maze_init(mz_lns, n_rows, n_cols, h, w, false); 


%% start the maze
simpleTaksMainLoop;

%% stop the maze
X=stop_maze(X);
pause(2);
close(X.am.fig_handle);
clear('X');