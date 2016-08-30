
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
which_maze = 'E';
mz_lns = makeSimpleMazeRev(which_maze);


% set a token to show the start point endpoint of the maze


% initialize the X variable
% this function does the following
% 1. initializes all the variables in the structure
% 2. makes the maze by calling the audioMaze constructor (audioMaze.m)
% 3. concocts the VR representation if the last argument is 'true'
% 4. sets up all the LSL outlets
% 5. sets up the LSL inlet (looks for pahsespace stream) and defines the
% phasespace markers of interest (head and hand markers)
X = maze_init_rev(mz_lns, n_rows, n_cols, h, w, false); 

% set the token map to give us the start and end points
if strcmp(which_maze, 'E')
   speakerLocs = [1,1; ... % start square
                  1,4]; % end square
 
end
% use the tokens (these should be more abstract, but it works ok for now)
X.tokens = mazeTokens(X.am, speakerLocs, []);

%% start the maze
simpleTaskMainLoop;

%% stop the maze
X=stop_maze(X);

%% close the velocity file and read it
if ~isempty(X.velocityFile)
    fclose(X.velocityFile);
end
fId = fopen('velocityFile', 'r');
formatSpec = '%f';
vel = fscanf(fId,formatSpec);
meanVel = mean(vel);


%% stop and clear the maze
X=stop_maze(X);
if ~isempty(X.velocityFile)
    fclose(X.velocityFile);
end
pause(2);
close(X.am.fig_handle);
clear all;

%% run once
simpleTaskCb;