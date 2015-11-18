function [mazePolygons mazeLines]= make_maze_polygons(row,col,pattern, wallThickness, randomSeed)
% usage  thyme = maze(30,45,'c');
% row - number of rows in the maze
% col - number of column in the maze
% pattern - random(r), vertical(v), horizontal(h), checkerboard(c), spiral(s), burst(b)

% Written by Rodney Meyer
% rodney_meyer@yahoo.com
%
% Construct graph system for maze. The graph entities are an id for each
% intersection(id), the physical row(rr) and column(cc) of the
% intersection, membership to a connected region (state), and a link to
% adjacent intersections(ptr_up ptr_down ptr_left ptr_right).
% Prior to "make_pattern" the maze has all of the walls intact and
% there are row*col of unconnected states. After "make_pattern" some of the
% walls are broken down and there is only one connected state for the maze.
% A broken wall(allowed passage) in some direction is signified by a negative
% value of the pointer in that direction. A solid wall(unallowed passage)
% in some direction is signified by a positive value of the pointer in that
% direction. The absolute value of the pointer is the id of the
% intersection in that direction.

if nargin < 5 % change the seed in each run
    rand('state',sum(100*clock)); 
else
    rand('state', randomSeed); 
end;

if nargin<4
    wallThickness = 0.1;
end;

[cc,rr]=meshgrid(1:col,1:row);
state = reshape([1:row*col],row,col); % state identifies connected regions
id = reshape([1:row*col],row,col); % id identifies intersections of maze

% create pointers to adjacent intersections
ptr_left = zeros(size(id));
ptr_up = zeros(size(id));
ptr_right = zeros(size(id));
ptr_down = zeros(size(id));

ptr_left(:,2:size(id,2)) = id(:,1:size(id,2)-1);
ptr_up(2:size(id,1),:) = id(1:size(id,1)-1,:);
ptr_right(:,1:size(id,2)-1) = id(:,2:size(id,2));
ptr_down(1:size(id,1)-1,:) = id(2:size(id,1),:);

% sort graph entities by id
the_maze = cat(2,reshape(id,row*col,1),reshape(rr,row*col,1),reshape(cc,row*col,1),reshape(state,row*col,1),...
    reshape(ptr_left,row*col,1),reshape(ptr_up,row*col,1),reshape(ptr_right,row*col,1),reshape(ptr_down,row*col,1)  );

the_maze = sortrows(the_maze);

id=the_maze(:,1);
rr=the_maze(:,2);
cc=the_maze(:,3);
state=the_maze(:,4);
ptr_left=the_maze(:,5);
ptr_up=the_maze(:,6);
ptr_right=the_maze(:,7);
ptr_down=the_maze(:,8);
clear the_maze;

% create a random maze
[state, ptr_left, ptr_up, ptr_right, ptr_down]=...
    make_pattern(row,col,pattern,id, rr, cc, state, ptr_left, ptr_up, ptr_right, ptr_down);

% show maze
%h=figure('color','white');
mazePolygons = []; mazeLines = [];
h = 0;
[mazePolygons mazeLines] = show_maze(mazePolygons, mazeLines, wallThickness, row, col, rr, cc, ptr_left, ptr_up, ptr_right, ptr_down,h);

return

function move_spot(src,evnt)
assignin('caller','key',evnt.Key)
return


function [mazePolygons mazeLines] = show_maze(mazePolygons, mazeLines, wallThickness,  row, col, rr, cc, ptr_left, ptr_up, ptr_right, ptr_down,h)
%figure(h)
%hold on;
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
% axis equal
% axis([0,col+1,0,row+1])
% %axis([.5,col+.5,.5,row+.5])
% axis off
% set(gca,'YDir','reverse')
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


function [state, ptr_left, ptr_up, ptr_right, ptr_down]=make_pattern(row,col,pattern,id, rr, cc, state, ptr_left, ptr_up, ptr_right, ptr_down)

while max(state)>1 % remove walls until there is one simply connected region
    tid=ceil(col*row*rand(15,1)); % get a set of temporary ID's
    cityblock=cc(tid)+rr(tid); % get distance from the start
    is_linked=(state(tid)==1); % The start state is in region 1 - see if they are linked to the start
    temp = sortrows(cat(2,tid,cityblock,is_linked),[3,2]); % sort id's by start-link and distance
    tid = temp(1,1); % get the id of the closest unlinked intersection
    
    % The pattern is created by selective random removal of vertical or
    % horizontal walls as a function of position in the maze. I find the
    % checkerboard option the most challenging. Other patterns can be added
    switch upper(pattern)
        case 'C' % checkerboard
            dir = ceil(8*rand);
            nb=3;
            block_size =  min([row,col])/nb;
            while block_size>12
                nb=nb+2;
                block_size =  min([row,col])/nb;
            end
            odd_even = (ceil(rr(tid)/block_size)*ceil(col/block_size) + ceil(cc(tid)/block_size));
            if odd_even/2 == floor(odd_even/2)
                if dir>6
                    dir=4;
                end
                if dir>4
                    dir=3;
                end
            else
                if dir>6
                    dir=2;
                end
                if dir>4
                    dir=1;
                end
            end
        case 'B' % burst
            dir = ceil(8*rand);
            if abs((rr(tid)-row/2))<abs((cc(tid)-col/2))
                if dir>6
                    dir=4;
                end
                if dir>4
                    dir=3;
                end
            else
                if dir>6
                    dir=2;
                end
                if dir>4
                    dir=1;
                end
            end
        case 'S' %spiral
            dir = ceil(8*rand);
            if abs((rr(tid)-row/2))>abs((cc(tid)-col/2))
                if dir>6
                    dir=4;
                end
                if dir>4
                    dir=3;
                end
            else
                if dir>6
                    dir=2;
                end
                if dir>4
                    dir=1;
                end
            end
        case 'V'
            dir = ceil(8*rand);
            if dir>6
                dir=4;
            end
            if dir>4
                dir=3;
            end
        case 'H'
            dir = ceil(8*rand);
            if dir>6
                dir=2;
            end
            if dir>4
                dir=1;
            end
        otherwise % random
            dir = ceil(4*rand);
    end
    
    % after a candidate for wall removal is found, the candidate must pass
    % two conditions. 1) it is not an external wall  2) the regions on
    % each side of the wall were previously unconnected. If successful the
    % wall is removed, the connected states are updated to the lowest of
    % the two states, the pointers between the connected intersections are
    % now negative.
    switch dir
        case -1
            
        case 1
            if ptr_left(tid)>0 & state(tid)~=state(ptr_left(tid))
                state( state==state(tid) | state==state(ptr_left(tid)) )=min([state(tid),state(ptr_left(tid))]);
                ptr_right(ptr_left(tid))=-ptr_right(ptr_left(tid));
                ptr_left(tid)=-ptr_left(tid);
            end
        case 2
            if ptr_right(tid)>0 & state(tid)~=state(ptr_right(tid))
                state( state==state(tid) | state==state(ptr_right(tid)) )=min([state(tid),state(ptr_right(tid))]);
                ptr_left(ptr_right(tid))=-ptr_left(ptr_right(tid));
                ptr_right(tid)=-ptr_right(tid);
            end
        case 3
            if ptr_up(tid)>0 & state(tid)~=state(ptr_up(tid))
                state( state==state(tid) | state==state(ptr_up(tid)) )=min([state(tid),state(ptr_up(tid))]);
                ptr_down(ptr_up(tid))=-ptr_down(ptr_up(tid));
                ptr_up(tid)=-ptr_up(tid);
            end
        case 4
            if ptr_down(tid)>0 & state(tid)~=state(ptr_down(tid))
                state( state==state(tid) | state==state(ptr_down(tid)) )=min([state(tid),state(ptr_down(tid))]);
                ptr_up(ptr_down(tid))=-ptr_up(ptr_down(tid));
                ptr_down(tid)=-ptr_down(tid);
            end
        otherwise
            dir
            error('quit')
    end
    
end
return