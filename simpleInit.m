function X = simpleInit(X)

%% create normalized maze geometry based on X.which_maze
X = makeSimpleMaze(X);

%% this function does the following
% 1. initializes all the variables in the structure
% 2. makes the maze by calling the audioMaze constructor (audioMaze.m) & plots maze
% 3. concocts the VR representation if the last argument is 'true'
% 4. sets up all the LSL outlets
% 5. sets up the LSL inlet (looks for pahsespace stream) and defines the
%    phasespace markers of interest (head and hand markers)

X = maze_init(X);

%% define the tokens (these should be more abstract, but it works ok for now)
X.tokens = mazeTokens(X.am, X.mazeGeometry.token_locs, []);

% use this to keep track of endpoints to hit
% of this list
X.tokenReached = zeros(1, length(X.mazeGeometry.token_locs));
X.tokenReached(1) = 1; % ensure that the starting point is 'reached'

% plot tokens on the maze
%start blue
plot(X.tokens.mocapLocs(1,1), X.tokens.mocapLocs(1,2), 'o', 'color', [.5 .5 .9], 'markersize',30, 'linewidth', 3);
%goal(s) red
plot(X.tokens.mocapLocs(2:end,1), X.tokens.mocapLocs(2:end,2), 'o', 'color', [.9 .5 .5], 'markersize',30, 'linewidth', 3);