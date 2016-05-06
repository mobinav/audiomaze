% class definition for an audio maze object
% this is a severe revision of the previous incantantaion of the audiomaze
% code by David Medine, SCCN
% begun 9-30-2015

classdef audioMaze      % audio maze object
    properties
        mazeWallsNrm    % normalized mxn by 4 matrix of wall segment endpoints
        mazeWalls       % the same but scaled by room dims
        mazeVecs        % vectors giving the line segments of each wall
        hasNeighbors    % structure elucidating which walls are touching
        isEnd           % for every endpoint, true if it is not touching, false otherwise
        isEndList       % vector of IDs for said endpoints (for searching)
        roomWallsNrm    % outer walls of the room (used to pinpoint audio)
        roomWalls       % the same but scaled by room dims
        roomDims        % room dimensions    
        mbyn            % mxn size of maze
        curPt           % current head position (needed?)
        nearestPoints   % list of current nearest points
        %mz_lns          % tmp local variable for debugging
        mz_plygns       % "
       
    end
    
    methods
%         (rm_height, rm_width, n_rows, n_cols, maze_lines)%
        function obj = audioMaze(rm_height, rm_width, n_rows, n_cols, maze_lines)%(rm_height, rm_width, n_rows, n_cols, style, rndmSeed)
            
           % use this to extend the walls so that they overlap a little
           overLapAmnt = 0; % this is probably stupid
           % .25; % in meters 
           
            % use the maze makers to make the maze
            %[~, mz_lns] = make_maze_polygons(n_rows, n_cols, style, 0, rndmSeed);
            mz_lns = maze_lines;
            % center the lines
            mz_lns = mz_lns-.5;

            % orient the maze correctly and normalize it
            tmp = mz_lns(:,1:2)/n_cols-.5;
            mz_lns(:,1:2) = (n_rows - mz_lns(:,3:4))/n_rows-.5;
            mz_lns(:,3:4) = tmp;
            
%             roomWidth = 8.5598;
%             roomHeight = 7.5565;
            
            % apply it to the object
            obj.mazeWallsNrm = mz_lns;
            obj.roomDims = [rm_height rm_width];
            obj.mbyn = [n_rows, n_cols];
            
            obj.mazeWalls(:,1:2) = obj.mazeWallsNrm(:,1:2) * obj.roomDims(2);
            obj.mazeWalls(:,3:4) = obj.mazeWallsNrm(:,3:4) * obj.roomDims(1);
  
            % find which walls neighbor which others, one to many
            obj.hasNeighbors = {};
            
            % the first four are always connected thus:
%             obj.hasNeighbors{1} = 4;
%             obj.hasNeighbors{2} = 3;
%             obj.hasNeighbors{3} = 2;
%             obj.hasNeighbors{4} = 1;
            
            % this finds if wall end points touch
            for n=1:length(obj.mazeWalls)
                cnt = 1;
                for m=1:length(obj.mazeWalls)  
                    if obj.mazeWalls(n,1:2:3) == obj.mazeWalls(m,1:2:3) | ...
                            obj.mazeWalls(n,2:2:4) == obj.mazeWalls(m,2:2:4) | ...
                            obj.mazeWalls(n,1:2:3) == obj.mazeWalls(m,2:2:4) | ...
                            obj.mazeWalls(n,2:2:4) == obj.mazeWalls(m,1:2:3) 
                        obj.hasNeighbors{n}(cnt) = m;
                        cnt = cnt+1;
                    end
                                        
                end
            end
            
            % we also need to check if a wall end is floating           
            obj.isEnd = {};
            for n=1:length(obj.mazeWalls)
                
                obj.isEnd{n}(1) = true;
                obj.isEnd{n}(2) = true;
                
                % this finds if they meet another endpoint
                for m=1:length(obj.mazeWalls)
                    if m~=n
                        if obj.mazeWalls(n,1:2:3) == obj.mazeWalls(m, 1:2:3) | ...
                                obj.mazeWalls(n,1:2:3) == obj.mazeWalls(m, 2:2:4)
                            obj.isEnd{n}(1) = false;
                        end

                        if obj.mazeWalls(n,2:2:4) == obj.mazeWalls(m, 1:2:3) | ...
                                obj.mazeWalls(n,2:2:4) == obj.mazeWalls(m, 2:2:4)
                            obj.isEnd{n}(2) = false;
                        end
                    end    
                end
            end
            
            % we also have to check if any walls intersect the outer walls
            % this will duplicate a neighbor if the loop above already caught it, but
            % we don't really care
            for n=5:length(obj.mazeWalls)
                cnt = length(obj.hasNeighbors{n})+1;
                for m=1:4 % the first 4 are always the outer walls, right?
%                     if isOnWall(obj.mazeWalls(n,1:2:3), obj.mazeWalls(m,1:2:3), obj.mazeWalls(m,2:2:4)) | ...
%                             isOnWall(obj.mazeWalls(n,2:2:4), obj.mazeWalls(m,1:2:3), obj.mazeWalls(m,2:2:4)) 
%                         obj.hasNeighbors{n}(cnt) = m;
%                         obj.hasNeighbors{m}(length(obj.hasNeighbors{m}) +1) = n;
%                         cnt = cnt+1;
                    if isOnWall(obj.mazeWalls(n,1:2:3), obj.mazeWalls(m,1:2:3), obj.mazeWalls(m,2:2:4))   
                        obj.hasNeighbors{n}(cnt) = m;
                        obj.hasNeighbors{m}(length(obj.hasNeighbors{m}) +1) = n;
                        obj.isEnd{n}(1) = false; % this also means it is not a floating end
                        cnt = cnt+1;
                    end
                    
                    if isOnWall(obj.mazeWalls(n,2:2:4), obj.mazeWalls(m,1:2:3), obj.mazeWalls(m,2:2:4)) 
                        obj.hasNeighbors{n}(cnt) = m;
                        obj.hasNeighbors{m}(length(obj.hasNeighbors{m}) +1) = n;
                        obj.isEnd{n}(2) = false; % this also means it is not a floating end
                        cnt = cnt+1;
                    end
                end
            end
            

            % if a wall has both ends true, find out which end is actually
            % dangling
            for n=5:length(obj.mazeWalls)
               if obj.isEnd{n}(1) + obj.isEnd{n}(1) == 2
                  for m=1:4
                      if isOnWall(obj.mazeWalls(n,1:2:3), obj.mazeWalls(m,1:2:3), obj.mazeWalls(m,2:2:4))
                        obj.isEnd{n}(1) = false;
                      elseif isOnWall(obj.mazeWalls(n,2:2:4), obj.mazeWalls(m,1:2:3), obj.mazeWalls(m,2:2:4))
                        obj.isEnd{n}(2) = false;
                      end
                  end
               end
            end
            
            % we also consider convex corners to be floating ends, so find
            % them
            % I'm not sure how to do this. It seems that convex and concave
            % corners are identical. Which side it is on is the determiner,
            % but judging this is pretty messy (unless there is some
            % trick).
            
%             for n=5:length(obj.mazeWalls)
%                if 1% two endpoints are touching
%                    
%                end
%             end
            
            % make a list of endpoints for easier searching
            obj.isEndList = {};
            cnt = 1;
            for n=1:length(obj.mazeWalls)
                if obj.isEnd{n}(1)
                    obj.isEndList{cnt} = obj.mazeWalls(n,1:2:3);
                    cnt = cnt+1;
                end
                
                if obj.isEnd{n}(2)
                    obj.isEndList{cnt} = obj.mazeWalls(n,2:2:4);
                    cnt = cnt+1;
                end
            end
            
            
            
            % extend the walls so that they overlap -- doesn't seem to do
            % much good, though
%             for n=1:length(obj.mazeWalls)
%                 % vertical or horizontal
%                 if obj.mazeWalls(n,1) == obj.mazeWalls(n,1)
%                    obj.mazeWalls(n,3) = obj.mazeWalls(n,3)+ (overLapAmnt * sign(obj.mazeWalls(n,3)));
%                    obj.mazeWalls(n,4) = obj.mazeWalls(n,4)+ (overLapAmnt * sign(obj.mazeWalls(n,4)));
%                 else
%                    obj.mazeWalls(n,1) = obj.mazeWalls(n,1)+ (overLapAmnt * sign(obj.mazeWalls(n,1)));
%                    obj.mazeWalls(n,2) = obj.mazeWalls(n,2)+ (overLapAmnt * sign(obj.mazeWalls(n,2)));
%                 end
%             end

           % calculate the line segment vectors
            for n=1:length(obj.mazeWalls)
                obj.mazeVecs(n,1:2) = obj.mazeWalls(n, 1:2:3) - obj.mazeWalls(n, 2:2:4);
            end%for
            
            obj.roomWallsNrm = [-.5 .5 .5 .5; ... % north (up)
                                -.5 .5 -.5 -.5; ... % south (down)
                                .5 .5 -.5 .5; ... % east (right)
                                -.5 -.5 -.5 .5]; % west (left)

            obj.roomWalls(:,1:2) = obj.roomWallsNrm(:,1:2) * obj.roomDims(1);
            obj.roomWalls(:,3:4) = obj.roomWallsNrm(:,3:4) * obj.roomDims(2);
            
            
            % enable the vr plotting options
            
            
        end
        
        function plotMaze(obj)

%            figure(11);clf; 
    % todo : fudge wall lengths to line up boundaries (hurray! MATLAB
    % graphics)
            for i=1:length(obj.mazeWalls(:,1))
                line(obj.mazeWalls(i,1:2), obj.mazeWalls(i,3:4), 'linewidth', 10, 'color',[.7 .7 1]);
%                 pause(.5);
            end
            pause(1)

                               
 
        end% function

        function [nearestPoints, distances] = findNearestPoints(obj, points)
            
            % go through all the walls -- consider concatenating adjacent
            % walls initially to minimize the search field? 
            % this requires some sophistication because we would consider
            % wall segments separated by jutting segments to be separate on
            % one side, but not the other
            
            nearestPoints = cell(length(points(:,1)),1); % create a cell array
            % there is one cell for each hand point we are testing
            % we could optimize by taking the centroid, but this may affect
            % believability
            % actually, now we do use centroid (median, actually), but this
            % has some unwanted side effects when markers drop out
            
            
            distances = zeros(length(obj.mazeWalls),length(points(:,1)));
            
            for m = 1:length(points(:,1))
                nearestPoints{m} = zeros(length(obj.mazeWalls),2);
                

                for n=1:length(obj.mazeWalls)
                    if points(m,3) == -100 % invalid point, ignore it
                        distances(n,m) = 9999999; % huge number
                    else

                        pd1 = pdist([points(m,1:2); obj.mazeWalls(n,1:2:3)],'euclidean');
                        pd2 = pdist([points(m,1:2); obj.mazeWalls(n,2:2:4)],'euclidean');
                        if pd1<=pd2 % ensure that we are finding the nearest far point on the wall
                            A = obj.mazeWalls(n,1:2:3); 
                            B = obj.mazeWalls(n,2:2:4);
                            distances(n,m) = pd1;
                        else
                            B = obj.mazeWalls(n,1:2:3);  
                            A = obj.mazeWalls(n,2:2:4);
                            distances(n,m) = pd2;
                        end

                        AB = B-A; % vector from A to B
                        normAB = norm(AB);
                        k = AB/normAB; % normal vector
                        t = dot((points(m,1:2) - A), k)/normAB;
                        if t<=0
                            nearestPoints{m}(n,1:2) = A;
                        elseif t>=1.0
                            nearestPoints{m}(n,1:2) = A;
                        else
                            nearestPoints{m}(n,1:2) = A + t*AB;
                            distances(n,m) = pdist([points(m,1:2); nearestPoints{m}(n,1:2)], 'euclidean');
                        end

                    end
                end     
            end
        end
        
        function audioProjection = findAudioProjection(obj, headPoint, wallPoint)

            horiz = 0; % horizontal and vertical slopes are special cases
            vert = 0; % so check and flag
            EW = 0; % flag for which set of walls we might be pointing at 

            vec = wallPoint - headPoint;
            if vec(1) == 0
                vert = 1;
            elseif vec(2) == 0
                EW = 1;
                horiz = 1;
            end
          
            m = vec(2)/vec(1); % might be inf or 0, but we don't care
            b = wallPoint(2) - m*wallPoint(1);

            audioProjection = [0,0];
            
            if vec(2)>0 % pointing right, test the 'North' wall
                if vert == 1
                    audioProjection(1) = headPoint(1);
                    audioProjection(2) = obj.roomWalls(3,1);
                else
                    audioProjection(1) = (obj.roomWalls(1,3)-b)/m;
                    % check if the y position is in the line segment
                    % if not, we have more work to do
                    if audioProjection(1)>obj.roomWalls(1,2) || audioProjection(1)<obj.roomWalls(1,1)
                        EW = 1;
                    else % otherwise, we are done
                        audioProjection(2) = obj.roomWalls(3,1);
                        EW = 0;
                    end
                end
            else % test 'South' wall
                if vert == 1
                    audioProjection(1) = headPoint(1);
                    audioProjection(2) = obj.roomWalls(4,2);
                else
                    audioProjection(1) = (obj.roomWalls(2,3)-b)/m;
                    % check if the y position is in the line segment
                    % if not, we have more work to do
                    if audioProjection(1)>obj.roomWalls(2,2) || audioProjection(1)<obj.roomWalls(2,1)
                        EW = 1;
                    else % otherwise, we are done
                        audioProjection(2) = obj.roomWalls(4,2);
                        EW = 0;
                    end
                end
            end

            if EW==1 % if we didn't get the correct yet wall, it must be 'east' or 'west'
                if vec(1)>0 % test the 'east' wall
                    if horiz == 1
                        audioProjection(2) = headPoint(2);
                        audioProjection(1) = obj.roomWalls(1,3);
                    else

                        audioProjection(2) = m*obj.roomWalls(3,1) + b;
                        % check if the y position is in the line segment
                        % if not, we have more work to do
                        if audioProjection(2)>obj.roomWalls(3,4) || audioProjection(2)<obj.roomWalls(3,3) % should always be false...
                        else % otherwise, we are done
                            audioProjection(1) = obj.roomWalls(1,3);
                        end
                    end
                else % test the 'west' wall
                    if horiz == 1
                        audioProjection(2) = headPoint(2);
                        audioProjection(1) = obj.roomWalls(2,4);
                    else
                        audioProjection(2) = m*obj.roomWalls(4,1) + b;
                        % check if the y position is in the line segment
                        % if not, we have more work to do
                        if audioProjection(2)>obj.roomWalls(4,4) || audioProjection(2)<obj.roomWalls(4,3)
                        else % otherwise, we are done
                            audioProjection(1) = obj.roomWalls(2,4);
                        end
                    end
                end    
            end
            
            % for debugging
%             figure;
%             fig_ln = linspace(min(obj.roomWalls(:,1)), max(obj.roomWalls(:,1)), 100);
%     
%             plot(fig_ln, m*fig_ln + b);
%             hold;
%             for i=1:length(obj.roomWalls(:,1))
%                 line(obj.roomWalls(i,1:2), obj.roomWalls(i,3:4),'linestyle','--', 'color','r');
%                 %pause(1);
%             end
%             
%             scatter(headPoint(1), headPoint(2), 'r');
%             scatter(wallPoint(1), wallPoint(2), 'g');
%             scatter(audioProjection(1), audioProjection(2), 'b');
%             hold off

                  
        end
        function TF = isPointFloating(obj, pt)
            TF = false;
            len = length(obj.isEndList);
            for n=1:len
                if pt==obj.isEndList{n}
                    TF = true;
                    break;
                end
            end  
        end
        
    end
    
end