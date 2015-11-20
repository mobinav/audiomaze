% function to create custom mazes for the audio maze
% the outer walls (and the northwest and southeast corners) are
% predetermined
% the rest of the maze information is supplied as a maze_representation
% argumen -- this is an array of 4xm*n elements, one for each panel of the
% maze
% the first column is the north panel (0 for open, 1 for closed)
% second for east, third for south, fourth for west
%
% for example, the panel given here (plusses for openenings, bars for walls):
%          N
%    | + + + + +
%    |         + 
%  W |         + E
%    |         +
%    | - - - - +
%          S
% would be shown as the row [0 0 1 1] in this representation
% 
%
% The order of tiles is right to left, row to row, starting from the 
% bottom right. That is to say a 3x3 maze would have panels in the  
% following order:
%
%  ------------- 
%  | 9 | 8 | 7 |
%  -------------
%  | 6 | 5 | 4 |
%  -------------
%  | 3 | 2 | 1 |
%  -------------
%
%
% As mentioned, the NorthWest (exit) and SouthEast (entrance) corners are
% predetermined, as are all the walls
%
% the return variable is an array of points that adhere to the coordinate
% system given by the random maze generator make_maaze_polygons
% this is then fed into the audioMaze creator to generate the
% maze object
% 
% 
% 
% Notes:
% The random maze builder delivers a maze that gets rotated in the
% audioMaze process. This means that the meaning of 'rows' and 'columns'
% gets flipped. The user of this function should design the maze in the
% coordinate system and orientation of the mobilab, the code will do the
% rotations to make it conform to the rest of the code in the maze.
% 
% 
% 
% Arguments:
%           rows                : rows in the maze
%           cols                : columns in the maze
%           maze_representation : the geometry of the maze 
% 
% 
% Returns:
%         maze_lines : an appropriately formated set of walls determining
%         the requested maze
% 
% 
% 
% 


function maze_lines = mazeBuilder(rows, cols, maze_representation)

    % check the dimensions
    if rows*cols ~= length(maze_representation(:,1))
        display('number of panels in does not match rows and cols');
        return;
    end
    
    % check that we have an entrance and exit
    if maze_representation(1,1) ~= 0 | maze_representation(rows*cols, 3) ~= 0
        display('NorthWest (first top) and SouthEast (last bottom) horizontal segments must be empty');
        return;
    end
    
    n = cols;
    m = rows; 
    
    maze_lines = [];
    
    % first, the outer walls
    maze_lines(1,:) = [.5, m+.5, .5, .5];
    maze_lines(2,:) = [.5, m+.5, n+.5, n+.5];
    maze_lines(3,:) = [.5, .5, 1.5, n+.5];
    maze_lines(4,:) = [m+.5, m+.5, .5, n-.5];
    
    figure;
    hold on;
    for i= 1:4
        line(maze_lines(i, 1:2), maze_lines(i, 3:4), 'linewidth', 3);
    end
    panel_cnt = 1;
    ln_cnt = 5;
    for i = 0:m-1
        for k = 0:n-1
            
            for l = 1:4
                if l == 1 % different for each side
                    if maze_representation(panel_cnt, l) == 1 % draw a line here
                        maze_lines(ln_cnt, 1) = i - .5;
                        maze_lines(ln_cnt, 2) = i - .5;
                        maze_lines(ln_cnt, 3) = k - .5;
                        maze_lines(ln_cnt, 4) = k + .5;

                        line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);

                        ln_cnt = ln_cnt + 1;
                    end
                end
                
                if l == 2 % different for each side
                    if maze_representation(panel_cnt, l) == 1 % draw a line here
                        maze_lines(ln_cnt, 1) = i - .5;
                        maze_lines(ln_cnt, 2) = i + .5;
                        maze_lines(ln_cnt, 3) = k + .5;
                        maze_lines(ln_cnt, 4) = k + .5;

                        line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
                        ln_cnt = ln_cnt + 1;
                    end
                end
                
                if l == 3 % different for each side
                    if maze_representation(panel_cnt, l) == 1 % draw a line here
                        maze_lines(ln_cnt, 1) = i + .5;
                        maze_lines(ln_cnt, 2) = i + .5;
                        maze_lines(ln_cnt, 3) = k - .5;
                        maze_lines(ln_cnt, 4) = k + .5;
                        
                        line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
                        ln_cnt = ln_cnt + 1;
                    end
                end
                
                if l == 4 % different for each side
                    if maze_representation(panel_cnt, l) == 1 % draw a line here
                        maze_lines(ln_cnt, 1) = i - .5;
                        maze_lines(ln_cnt, 2) = i + .5;
                        maze_lines(ln_cnt, 3) = k - .5;
                        maze_lines(ln_cnt, 4) = k - .5;

                        line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
                        ln_cnt = ln_cnt + 1;
                    end
                end
                
            end
            panel_cnt = panel_cnt + 1;
        end
    end
    hold off;
    
end