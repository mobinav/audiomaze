% %%
% maze_b = [1,0,;  0, 1; 1, 0; 0, 0; 1, 1; 1, 0; 0, 1; 0, 1; 1, 0;];
% 
% f = mazeBuilder(3,3,maze_b);
% %%
% am = audioMaze(1, 1, 3, 3, f);
% figure;
% am.plotMaze;

%%
% To specify any maze made up os mxn rows and columns, we simply need to
% note the shape of the outer walls and whther or not each rectangle on the
% grid has a wall beneath it or to the right of it.
%
% In the case of a 3x3 maze, the grid looks like this 
%
%  ------------- 
%  | 1 | 2 | 3 |
%  -------------
%  | 4 | 5 | 5 |
%  -------------
%  | 7 | 8 | 9 |
%  -------------
%
%
% The SouthEast (rectangle 1, exit) and NorhtEast (rectangle 9, entrance) corners are
% predetermined, as are all the outer walls.
%
% In order to specify the maze, for eac panel give a 0 (open) or 1 (closed)
% for the bottom, and right passages respectively. For example the following
% maze (plusses are for openings, bars for walls):
%
%  -+++--------- 
%  | 1 | 2 + 3 |
%  -+++-----+++-
%  | 4 + 5 | 5 |
%  -+++-----+++-
%  | 7 + 8 + 9 |
%  ---------+++-
%
% If a gird rectangle touches a wall either below it or to the right of it,
% it doesn't matter what you put, unless it is the final rectangle. This
% should always have 0 as it's first element. Otherwise, there is no way in
% to the maze.

maze_c = [0,1; 1,0; 0,0; 0,0; 1,1; 0,0; 0,0; 0,0; 0,0];
%maze_c = ones(size(maze_c));
[polys, lines] = make_maze_polygons_nr(3,3,0, maze_c(:,1), maze_c(:,2));
%%
am = audioMaze(1, 1, 3, 3, lines);
figure;
am.plotMaze;
%%
set(gca, 'XDir', 'reverse');
set(gca, 'YDir', 'reverse');
set(gca, 'YLim', [-.6 .6]);
set(gca, 'XLim', [-.6 .6]);