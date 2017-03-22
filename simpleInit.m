function X = simpleInit(X)

% maze dimensions
n_rows = 5;
n_cols = 5;

% room dimensions
% w = 6;
% h = 6.5;

w = 5;
h = 5;

X.random_seed = 0;

[mz_lns, token_locs] = makeSimpleMazeRev(X.which_maze);

% initialize the X variable
% this function does the following
% 1. initializes all the variables in the structure
% 2. makes the maze by calling the audioMaze constructor (audioMaze.m)
% 3. concocts the VR representation if the last argument is 'true'
% 4. sets up all the LSL outlets
% 5. sets up the LSL inlet (looks for pahsespace stream) and defines the
%    phasespace markers of interest (head and hand markers)
mazeInfo = maze_init_rev(mz_lns, n_rows, n_cols, h, w, false); 

X = copyfields(mazeInfo, X,[],'preserve');

% use the tokens (these should be more abstract, but it works ok for now)
X.tokens = mazeTokens(X.am, token_locs, []);

% use this to keep track of endpoints to hit
% of this list
X.tokenReached = zeros(1, length(token_locs));
X.tokenReached(1) = 1; % ensure that the starting point is 'reached'

% plot them on the maze
%start blue
plot(X.tokens.mocapLocs(1,1), X.tokens.mocapLocs(1,2), 'o', 'color', [.5 .5 .9], 'markersize',30, 'linewidth', 3);
%goal(s) red
plot(X.tokens.mocapLocs(2:end,1), X.tokens.mocapLocs(2:end,2), 'o', 'color', [.9 .5 .5], 'markersize',30, 'linewidth', 3);


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
