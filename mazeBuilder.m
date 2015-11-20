% function to create custom mazes for the audio maze
% 
% It turns out that one can entirely describe a gridded maze provided one
% knows the outer walls and whether or not one can proceed either to the
% right or downward starting in the top left.
%
% The order of tiles is left to right, row to row, starting from the 
% top left. That is to say a 3x3 maze would have panels in the  
% following order:
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
% The NorthWest (exit) and SouthEast (entrance) corners are
% predetermined, as are all the outer walls
%
% In order to specify the maze, for eac panel give a 0 (open) or 1 (closed)
% for the right and bottom passages respectively. For example the following
% maze (plusses are for openings, bars for walls):
%
%  -+++--------- 
%  | 1 | 2 + 3 |
%  -+++-----+++-
%  | 4 X 5 | 5 |
%  -+++-----+++-
%  | 7 X 8 X 9 |
%  ---------+++-
%
% Would be written:
% maze = [1, 0;  ...% 1
%         0, 1;  ...% 2
%         1, 0;  ...% 3
%         0, 0;  ...% 4
%         1, 1;  ...% 5
%         1, 0;  ...% 6
%         0, 1;  ...% 7
%         0, 1;  ...% 8
%         1, 0;];   % 9
%
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
% gets reversed. The user of this function should design the maze in the
% coordinate system and orientation of the mobilab, the code will do the
% rotation to make it conform to the rest of the code in the maze. But, if
% you inspect the maze using audioMaze.plotMaze, its orientation is flipped
% on both the y and x axes. This is actually how the maze is represented in
% adherence to the mocap orientation. It is flipped graphically when the
% maze is running to make it more human-readable.
% 
% The outer walls are always the same, with the exit at the top of the
% left most panel and the entrance at the bottom of the righ most. The
% inner walls are specified. The algorithm only draws the 
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
    for i = 1:m
        for k = 1:n
            
            for l = 1:2 % only draw the right and bottom segments
%                 if l == 1 & i~=1 % skip the top on the top row
%                     if maze_representation(panel_cnt, l) == 1 % draw a line here
%                         maze_lines(ln_cnt, 1) = i - .5;
%                         maze_lines(ln_cnt, 2) = i - .5;
%                         maze_lines(ln_cnt, 3) = k - .5;
%                         maze_lines(ln_cnt, 4) = k + .5;
% 
%                         line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
% 
%                         ln_cnt = ln_cnt + 1;
%                     end
%                 end
                
                if l == 1 & k~=n % skip the right on the last column 
                    if maze_representation(panel_cnt, l) == 1 % draw a line here
                        maze_lines(ln_cnt, 1) = i - .5;
                        maze_lines(ln_cnt, 2) = i + .5;
                        maze_lines(ln_cnt, 3) = k + .5;
                        maze_lines(ln_cnt, 4) = k + .5;

                        line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
                        ln_cnt = ln_cnt + 1;
                    end
                end
                
                if l == 2 & i~=m % skip the bottom on the bottom row 
                    if maze_representation(panel_cnt, l) == 1 % draw a line here
                        maze_lines(ln_cnt, 1) = i + .5;
                        maze_lines(ln_cnt, 2) = i + .5;
                        maze_lines(ln_cnt, 3) = k - .5;
                        maze_lines(ln_cnt, 4) = k + .5;
                        
                        line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
                        ln_cnt = ln_cnt + 1;
                    end
                end
                
%                 if l == 4 & i~=1 % skip the left 
%                     if maze_representation(panel_cnt, l) == 1 % draw a line here
%                         maze_lines(ln_cnt, 1) = i - .5;
%                         maze_lines(ln_cnt, 2) = i + .5;
%                         maze_lines(ln_cnt, 3) = k - .5;
%                         maze_lines(ln_cnt, 4) = k - .5;
% 
%                         line(maze_lines(ln_cnt, 1:2), maze_lines(ln_cnt, 3:4), 'linewidth', 3);
%                         ln_cnt = ln_cnt + 1;
%                     end
%                 end
                
            end
            panel_cnt = panel_cnt + 1;
        end
    end
    hold off;
    


    
    
end