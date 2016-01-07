% Adapted from Rodney Meyer's file, make_maze_polygons.m. Adaptation for
% AudioMaze at SCCN, UCSD by David Medine.

% Everything is the same, but this code does not use a random seed. Instead
% information as to whether or not a current maze square opens to the right
% or down is supplied. This will completely characterize the maze.

function [mazePolygons mazeLines]= make_maze_polygons_nr(row,col, wallThickness, ptr_right, ptr_down)
% usage  thyme = maze(30,45,'c');
% row - number of rows in the maze
% col - number of column in the maze
% wallThickness - thickness of the wall
% ptr_right - rowxcol array of right passages
% ptr_down - rowxcol array of down passages

[cc,rr]=meshgrid(1:col,1:row);
state = reshape([1:row*col],row,col); % state identifies connected regions
id = reshape([1:row*col],row,col); % id identifies intersections of maze

% create pointers to adjacent intersections
ptr_left = zeros(size(id));
ptr_up = zeros(size(id));

ptr_left(:,2:size(id,2)) = id(:,1:size(id,2)-1);
ptr_up(2:size(id,1),:) = id(1:size(id,1)-1,:);

% sort graph entities by id
the_maze = cat(2,reshape(id,row*col,1),reshape(rr,row*col,1),reshape(cc,row*col,1),reshape(state,row*col,1),...
    reshape(ptr_left,row*col,1),reshape(ptr_up,row*col,1),reshape(ptr_right,row*col,1),reshape(ptr_down,row*col,1)  );

the_maze = sortrows(the_maze);

id=the_maze(:,1);
rr=the_maze(:,2);
cc=the_maze(:,3);
state=the_maze(:,4);

clear the_maze;

% create a random maze

% show maze
%h=figure('color','white');
mazePolygons = []; mazeLines = [];
h = 0;
[mazePolygons mazeLines] = show_maze(mazePolygons, mazeLines, wallThickness, row, col, rr, cc, ptr_right, ptr_down);

return

function move_spot(src,evnt)
assignin('caller','key',evnt.Key)
return


function [mazePolygons mazeLines] = show_maze(mazePolygons, mazeLines, wallThickness,  row, col, rr, cc, ptr_right, ptr_down)
%figure(h)
%hold on;
% figure;
% hold on;
% axis([.5,col+.5,.5,row+.5])

[mazePolygons mazeLines] = line_and_polygon([.5,col+.5],[.5,.5], mazePolygons,mazeLines, wallThickness); % draw top border
[mazePolygons mazeLines] = line_and_polygon([.5,col+.5],[row+.5,row+.5], mazePolygons,mazeLines, wallThickness); % draw bottom border
[mazePolygons mazeLines] = line_and_polygon([.5,.5],[1.5,row+.5], mazePolygons,mazeLines, wallThickness); % draw left border
[mazePolygons mazeLines] = line_and_polygon([col+.5,col+.5],[.5,row-.5], mazePolygons,mazeLines, wallThickness);  % draw right border



for ii=1:length(ptr_right)
    if ptr_right(ii)>0 % right passage blocked
        [mazePolygons mazeLines] = line_and_polygon([cc(ii)+.5,cc(ii)+.5],[rr(ii)-.5,rr(ii)+.5], mazePolygons, mazeLines,wallThickness);
        %hold on
        
    end
    if ptr_down(ii)>0 % down passage blocked
        [mazePolygons mazeLines] = line_and_polygon([cc(ii)-.5,cc(ii)+.5],[rr(ii)+.5,rr(ii)+.5], mazePolygons, mazeLines,wallThickness);
        %hold on
    end

end
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
return


function [mazePolygons mazeLines] = line_and_polygon(x,y, mazePolygons,mazeLines, wallThickness)
%line(x,y);

for id = 1:(length(x)-1)
    % make a perpendicular vector
    dx = x(id+1) - x(id);
    dy = y(id+1) - y(id);
    
   
    % extend both sides by width/2, to make polygons connect
    directionVector = [dx dy];
    directionVector = directionVector / norm(directionVector, 'fro');
    
    extensionRatio = 1;
    x(id) = x(id) - wallThickness * extensionRatio * directionVector(1);
    x(id+1) = x(id+1) + wallThickness * extensionRatio * directionVector(1);
    
    y(id) = y(id) - wallThickness * extensionRatio * directionVector(2);
    y(id+1) = y(id+1) + wallThickness * extensionRatio * directionVector(2);
    
    perpendicularVector = [-dy dx];
    
    
    
    perpendicularVector = wallThickness * perpendicularVector / norm(perpendicularVector, 'fro');
    
    polygonX = [x(id)-perpendicularVector(1) x(id+1)-perpendicularVector(1) x(id+1)+perpendicularVector(1) x(id)+perpendicularVector(1)];
    polygonY = [y(id)-perpendicularVector(2) y(id+1)-perpendicularVector(2) y(id+1)+perpendicularVector(2) y(id)+perpendicularVector(2)];
    
    % close the polgon
    polygonX = [polygonX polygonX(1)];
    polygonY = [polygonY polygonY(1)];
    
    % plot(polygonX, polygonY,'r');
   
    if isempty(mazePolygons)
       mazePolygons(1,:) = polygonX;
       mazePolygons(2,:) = polygonY;
    else
        [mazePolygonXs mazePolygonYs] = polybool('union', mazePolygons(1,:),  mazePolygons(2,:), polygonX, polygonY);
        mazePolygons = [mazePolygonXs; mazePolygonYs];
    end;
    
    if isempty(mazeLines)
        mazeLines = [x y];
    else
        mazeLines = [mazeLines; x y];
    end;    
end;
return

