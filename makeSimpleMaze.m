function X = makeSimpleMaze(X)
% makeSimpleMaze define maze geometry of simple mazes (first pilot, I, U, T, + etc)
%
% X = makeSimpleMaze(X)
%
%   returns X.mazeGeometry, including lines, polygons, wall and token
%   definitions
%
% make simple mazes from Levy-Tzedek S, Maidenbaum S, Amedi A, Lackner J (2016)
%Aging and Sensory Substitution in a Virtual Navigation Task. PLoS ONE
%11(3): e0151593. doi:10.1371/journal.pone.0151593
%
% e.g. "D"
% x
% x
% x x x
%     x
%     x

% for encoding system details, see mazeBuilder.m
% briefly, grid is numbered starting in upper left corner, by rows
%   1 2 3 4 5
%   6 7 8 9 10
%
% and we define the presence of a right or bottom wall in each grid square
% using a #cell x 2 array, first column is right, second is bottom
%
% this happens to be the system our original random maze-building code
% used, so we have just kept it

maze = zeros(X.mazeinfo.n_rows * X.mazeinfo.n_cols, 2);

%token_locs are row,column with origin in upper left corner!
% it's an awkward mix of row/column and x/y, but mazes are defined in
% row,column matrix order (origin upper left corner)
% upper left is NW corner of room. Top row is N, bottom row S; left column
% is W, rightmost is E...

%column indexes for shorthand and readibility
R=1;
B=2; 

switch upper(X.which_maze)
      
  % I shape
  case 'A'
      maze([2 7 12 17 22], R) = 1;
      maze([3 8 13 18 23], R) = 1;
    token_locs = [5,3; ... % start square (bottom row, middle)
        1,3]; % end square
  
  % L shape (not used in initial experiment)
  case 'B'
      maze(1, B) = 1; %end of vertical leg
      maze([6 11 16],R) = 1; %rt wall of vertical leg; left wall taken care of by maze outer wall
      maze([17 18 19 ], B) = 1; %top wall of bottom leg; bottom taken care of by maze outer wall
      maze(24, R) = 1; %end of horizontal leg
    token_locs = [5,4; ... % start square
        2,1]; % end square
      
   % U shape
   case 'C'
       maze([1 2 3 4], B) = 1;
       maze([7 8], B) = 1;
       maze([11 16 21], R) = 1;
       maze([13 18 23], R) = 1;
       maze([9 14 19 24], R) = 1;
    token_locs = [5,4; ... % start square
        5,1]; % end square
  
  % Z shape (not used in initial experiment)
  case 'D'
    maze(1,2)=1;
    maze(2,2)=1;
    maze(3,1)=1;
    maze(7,1)=1;
    maze(8,1)=1;
    maze(12,1)=1;
    maze(13,1)=1;
    maze(14,2)=1;
    maze(15,2)=1;
    maze(17,1)=1;
    maze(18,2)=1;
    maze(19,2)=1;
    maze(20,2)=1;
    token_locs = [1,1; ... % start square
        4,5]; % end square

  % T shape
  case 'E'
    maze([1 2 4 5], B) = 1; %bottom of top corridor
    maze([7 12 17 22], R) = 1; %left wall of up corridor
    maze([8 13 18 23], R) = 1; %right side of up corridor
    token_locs = [5,3; ... % start square
        1,1; 1,5]; % end squares

  % X shape
  case 'F'
      maze([ 2  7  17 22], R) = 1;
      maze([ 3  8  18 23], R) = 1;
      maze([ 6  7   9 10], B) = 1;
      maze([11 12  14 15], B) = 1;
    token_locs = [5,3; ... % start square
        3,1; 3,5; 1,3]; % end squares
      
  otherwise
   error('unknown maze code') 
end

X.mazeGeometry.walls = maze;
X.mazeGeometry.token_locs = token_locs;

%% define normalized geometery: lines and wall & proximity polygons
% need to translate thickness, etc from meters into normalized coords. This
% is perfect in case of 1:1 aspect ratio, but we take mean scale in case of
% non 1:1
mazeScale = mean([X.mazeinfo.h/X.mazeinfo.n_rows X.mazeinfo.w/X.mazeinfo.n_cols]);
normWallThickness = X.mazeinfo.wallThickness / mazeScale;
normProximityThickness = X.mazeinfo.handProximityThresh*2 / mazeScale;

%% define lines and wall polygons
[~,X.mazeGeometry.maze_lines]          = make_maze_polygons_nr(X.mazeinfo.n_rows, X.mazeinfo.n_cols, 0,                      maze(:,R),maze(:,B), X.mazeinfo.hasExits);
[X.mazeGeometry.maze_poly_wall,~]      = make_maze_polygons_nr(X.mazeinfo.n_rows, X.mazeinfo.n_cols, normWallThickness,      maze(:,R),maze(:,B), X.mazeinfo.hasExits);
[X.mazeGeometry.maze_poly_proximity,~] = make_maze_polygons_nr(X.mazeinfo.n_rows, X.mazeinfo.n_cols, normProximityThickness, maze(:,R),maze(:,B), X.mazeinfo.hasExits);

%% debug plot
if 1
    figure
    plot(X.mazeGeometry.maze_poly_wall(1,:),X.mazeGeometry.maze_poly_wall(2,:))
    hold on
    plot(X.mazeGeometry.maze_poly_proximity(1,:),X.mazeGeometry.maze_poly_proximity(2,:))
    plot(X.mazeGeometry.maze_lines(:,1:2)', X.mazeGeometry.maze_lines(:,3:4)', 'linewidth',4)
    axis equal
end

