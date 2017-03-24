function [mazePolygons, mazeLines]= make_maze_polygons_nr(row,col, wallThickness, ptr_right, ptr_down, exits)
% make_maze_polygons_nr  generate geometry for 'nonrandom' mazes
%
%   [mazePolygons mazeLines]= make_maze_polygons_nr(row,col, wallThickness, ptr_right, ptr_down, exits)
%
% Adapted from Rodney Meyer's file, make_maze_polygons.m. Adaptation for
% AudioMaze at SCCN, UCSD by David Medine.

% Everything is the same, but this code does not use a random seed. Instead
% information as to whether or not a current maze square opens to the right
% or down is supplied. This will completely characterize the maze.
%
% row - number of rows in the maze
% col - number of column in the maze
% wallThickness - thickness of the wall (normalized)
% ptr_right - rowxcol array of right walls
% ptr_down - rowxcol array of down walls
% exits - true, make exits in NW and SE corners of maze (default false)
%
% mazePolygons n x 2, coordinates of polygon defining maze (useful forplotting)
% mazeLines    n x 4, line segments (x1 x2 y1 y2) of lines defining walls
%                       consists of 4 outer walls and inner walls

if nargin < 6
    exits = false;
end

[cc,rr]=meshgrid(1:col,1:row);
% NB (JRI 3/17) Must transpose because our maze definition is row-major (count along
% columns) while matlab is column-major! Remember c=x, r=y
rr=rr'; cc=cc';
mazePolygons = []; mazeLines = [];
[mazePolygons, mazeLines] = show_maze(mazePolygons, mazeLines, wallThickness, row, col, rr, cc, ptr_right, ptr_down, exits);

return


function [mazePolygons, mazeLines] = show_maze(mazePolygons, mazeLines, wallThickness,  row, col, rr, cc, ptr_right, ptr_down, exits)

%define outer walls
if exits
    [mazePolygons, mazeLines] = line_and_polygon([.5,col-.5],[.5,.5], mazePolygons,mazeLines, wallThickness); % draw top border (with opening)
    [mazePolygons,  mazeLines] = line_and_polygon([1.5,col+.5],[row+.5,row+.5], mazePolygons,mazeLines, wallThickness); % draw bottom border (with opening)
    [mazePolygons,  mazeLines] = line_and_polygon([.5,.5],[.5,row+.5], mazePolygons,mazeLines, wallThickness); % draw left border
    [mazePolygons,  mazeLines] = line_and_polygon([col+.5,col+.5],[.5,row+.5], mazePolygons,mazeLines, wallThickness);  % draw right border
else
    [mazePolygons,  mazeLines] = line_and_polygon([.5,col+.5],[.5,.5], mazePolygons,mazeLines, wallThickness); % draw top border (no opening)
    [mazePolygons,  mazeLines] = line_and_polygon([.5,col+.5],[row+.5,row+.5], mazePolygons,mazeLines, wallThickness); % draw bottom border (no opening)
    [mazePolygons,  mazeLines] = line_and_polygon([.5,.5],[.5,row+.5], mazePolygons,mazeLines, wallThickness); % draw left border
    [mazePolygons,  mazeLines] = line_and_polygon([col+.5,col+.5],[.5,row+.5], mazePolygons,mazeLines, wallThickness);  % draw right border
end


for ii=1:length(ptr_right)
    if ptr_right(ii)>0 % right passage blocked
        [mazePolygons,  mazeLines] = line_and_polygon([cc(ii)+.5,cc(ii)+.5],[rr(ii)-.5,rr(ii)+.5], mazePolygons, mazeLines,wallThickness);
        %hold on
        
    end
    if ptr_down(ii)>0 % down passage blocked
        [mazePolygons,  mazeLines] = line_and_polygon([cc(ii)-.5,cc(ii)+.5],[rr(ii)+.5,rr(ii)+.5], mazePolygons, mazeLines,wallThickness);
        %hold on
    end

end

%% finally, need to flip up/down, since this was written to grow the maze downwards (N->S, from perspective of control room), while our Y coordinate 
% JRI 3/17
if ~isempty(mazePolygons) 
    mazePolygons(2,:) = (col+1) - mazePolygons(2,:); %0.5 -> 5.5, 5.5 -> 0.5 (col+1 because we have that many horizontal walls)
end
mazeLines(:,3:4) = (col+1) - mazeLines(:,3:4);

% 
% for n=1:length(mazeLines(:,1))
%     line(mazeLines(n, 1:2), mazeLines(n, 3:4), 'linewidth', 3);
%     pause(.5);
% end
% axis equal
% axis([0,col+1,0,row+1])
% %axis([.5,col+.5,.5,row+.5])
% axis off
% set(gca,'YDir','reverse')
% hold off;

function [mazePolygons,  mazeLines] = line_and_polygon(x,y, mazePolygons,mazeLines, wallThickness)
%line(x,y);

for id = 1:(length(x)-1)
    % make direction and perpendicular vectors, to enable thickness
    dx = x(id+1) - x(id);
    dy = y(id+1) - y(id);
    
    % extend both ends by width/2, to make polygons connect
    directionVector = [dx dy];
    directionVector = directionVector / norm(directionVector, 'fro');
    
    extensionRatio = 1.01; %slightly longer to ensure overlap for polygon unions
    x(id) = x(id) - wallThickness/2 * extensionRatio * directionVector(1);
    x(id+1) = x(id+1) + wallThickness/2 * extensionRatio * directionVector(1);
    
    y(id) = y(id) - wallThickness/2 * extensionRatio * directionVector(2);
    y(id+1) = y(id+1) + wallThickness/2 * extensionRatio * directionVector(2);
    
    %add width to the wall
    perpendicularVector = [-dy dx];
    perpendicularVector = wallThickness/2 * perpendicularVector / norm(perpendicularVector, 'fro');
    
    polygonX = [x(id)-perpendicularVector(1) x(id+1)-perpendicularVector(1) x(id+1)+perpendicularVector(1) x(id)+perpendicularVector(1)];
    polygonY = [y(id)-perpendicularVector(2) y(id+1)-perpendicularVector(2) y(id+1)+perpendicularVector(2) y(id)+perpendicularVector(2)];
    
    % close the polgon
    polygonX = [polygonX polygonX(1)];
    polygonY = [polygonY polygonY(1)];
    
    %make clockwise
    [polygonX, polygonY] = poly2cw(polygonX, polygonY);
    
    % plot(polygonX, polygonY,'r');
   
    if isempty(mazePolygons)
       mazePolygons(1,:) = polygonX;
       mazePolygons(2,:) = polygonY;
    else
        [mazePolygonXs,  mazePolygonYs] = polybool('union', mazePolygons(1,:),  mazePolygons(2,:), polygonX, polygonY);
        mazePolygons = [mazePolygonXs; mazePolygonYs];
    end;
    
    if isempty(mazeLines)
        mazeLines = [x y];
    else
        mazeLines = [mazeLines; x y];
    end  
end

