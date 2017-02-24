
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
global which_maze; 
%which_maze = 'E';
global random_seed; 
random_seed = 0;
global trial_number; 
%trial_number = 1;


mz_lns = makeSimpleMazeRev(which_maze);

% initialize the X variable
% this function does the following
% 1. initializes all the variables in the structure
% 2. makes the maze by calling the audioMaze constructor (audioMaze.m)
% 3. concocts the VR representation if the last argument is 'true'
% 4. sets up all the LSL outlets
% 5. sets up the LSL inlet (looks for pahsespace stream) and defines the
%    phasespace markers of interest (head and hand markers)
X = maze_init_rev(mz_lns, n_rows, n_cols, h, w, false); 

% set the token map to give us the start and end points
if strcmp(which_maze, 'A')
    speakerLocs = [1,3; ... % start square
                   5,3]; % end square

end
if strcmp(which_maze, 'B')
    speakerLocs = [4,1; ... % start square
        1,4]; % end square

end
if strcmp(which_maze, 'C')
    speakerLocs = [1,1; ... % start square
        1,4]; % end square

end
if strcmp(which_maze, 'D')
    speakerLocs = [1,1; ... % start square
        4,5]; % end square

end
if strcmp(which_maze, 'E')
    speakerLocs = [1,3; ... % start square
        5,1;5,5]; % end squares

end
if strcmp(which_maze, 'F')
    speakerLocs = [1,3; ... % start square
        3,1;3,5;5,3]; % end squares

end




% use the tokens (these should be more abstract, but it works ok for now)
X.tokens = mazeTokens(X.am, speakerLocs, []);

% use this to keep track of endpoints to hit
% of this list
X.tokenReached = zeros(1, length(speakerLocs));
X.tokenReached(1) = 1; % ensure that the starting point is 'reached'

% plot them on the maze
% skip the last two
plot(X.tokens.mocapLocs(1,1), X.tokens.mocapLocs(1,2), 'o', 'color', [.5 .5 .9], 'markersize',30, 'linewidth', 3);
plot(X.tokens.mocapLocs(2:end,1), X.tokens.mocapLocs(2:end,2), 'o', 'color', [.9 .5 .5], 'markersize',30, 'linewidth', 3);


%% start the maze
infoData = [which_maze, num2str(random_seed), num2str(trial_number)];
X.LSL.emitInfo(which_maze, random_seed, trial_number);
simpleTaskMainLoop;


%% stop the maze
% X=stop_maze(X);
% 
% 
% %% close the velocity file and read it
% X=stop_maze(X);
% if ~isempty(X.velocityFile)
%     fclose(X.velocityFile);
% end
% fId = fopen('velocityFile', 'r');
% formatSpec = '%f';
% vel = fscanf(fId,formatSpec);
% meanVel = mean(vel)
% 
% 
% % emit stats here
% statData = [meanVel, X.nearWallCntHand, X.touchingWallCntHand, X.totalTimeNearWallHand, X.totalTimeTouchingWallHand, X.nearWallCntHead, X.touchingWallCntHead, X.totalTimeNearWallHead, X.totalTimeTouchingWallHead];
% X.LSL.emitStats(statData);
% 
% %% stop and clear the maze
% X=stop_maze(X);
% if ~isempty(X.velocityFile)
%     fclose(X.velocityFile);
% end
% pause(2);
% close(X.am.fig_handle);
% clear all;
% 
% 
% %% run once (for debugging)
% simpleTaskCb;
% 
