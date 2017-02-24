global X;
global which_maze;
which_maze = 'B';
% maze dimensions
n_rows = 5;
n_cols = 5;

% room dimensions
w = 6;
h = 6.5;
mz_lns = makeSimpleMazeRev(which_maze);
X = maze_init_rev(mz_lns, n_rows, n_cols, h, w, false); 

if strcmp(which_maze, 'B')
    speakerLocs = [4,1; ... % start square
        1,4]; % end square

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

%%
simpleTaskMainLoop;

%%
stop_maze;

%% run once (for debugging)
simpleTaskCb;

%%
tearDown

