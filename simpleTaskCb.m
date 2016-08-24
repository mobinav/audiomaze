% callback function that is the main loop of the simpleTask 
% implementation of the audiomaze
function simpleTaskCb

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 0. initialize variables
    % the 'everything' structure
    global X
    
    % to count frames
    persistent frameNumber 
    if isempty(frameNumber)
        frameNumber = 0;
    end
    
    % if we want to use the last good marker data to fill in bad markers
    persistent lastMarkers
    
    % other persistent variables, previous frame data
    persistent lastWallIdHead lastWallIdHand lastHeadPosition
    if isempty(lastWallIdHead)
        lastWallIdHead = 0;
    end
    if isempty(lastWallIdHand)
        lastWallIdHand = 0;
    end
    if isempty(lastHeadPosition)
        lastHeadPosition = [0 0];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. get current time of this frame
    
    time_is = lsl_local_clock(X.LSL.lib);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2. get the latest phasespace input
    
    % pull the newest sample and organize the data
    [sample, stamps] = X.LSL.phasespace.inlet.pull_chunk();
    if ~isempty(sample)    
        ys = double(sample(1:4:end-1,end));
        zs = double(sample(2:4:end-1,end));
        xs = double(sample(3:4:end-1,end));
        conf = double(sample(4:4:end-1,end));

        X.mocap.markerPosition = [ys, xs, zs, conf];
        
        goodHandMarkers=[];
        goodHeadMarkers=[];
        for n=1:length(X.mocap.markers.rightHand)
            if X.mocap.markerPosition(X.mocap.markers.rightHand(n),4)~=-1
                goodHandMarkers(n,:) = X.mocap.markerPosition(X.mocap.markers.rightHand(n),:);
            end
        end
        
        for n=1:length(X.mocap.markers.head)
            if X.mocap.markerPosition(X.mocap.markers.head(n),4)~=-1
                goodHeadMarkers(n,:) = X.mocap.markerPosition(X.mocap.markers.head(n),:);
            end
        end
        
        
        if isempty(lastMarkers)
            lastMarkers = X.mocap.markerPosition;
        end

        goodMarkerIds = find(X.mocap.markerPosition(:,4) ~= -1);
        badMarkerIds = find(X.mocap.markerPosition(:,4) == -1);

        % do we want to use the last set of good markers?
        % anyway, here it is
        X.mocap.markerPosition(badMarkerIds,:) = lastMarkers(badMarkerIds,:);
        lastMarkers(goodMarkerIds,:) =  X.mocap.markerPosition(goodMarkerIds,:);
    end
    
    if frameNumber >= 2;%5 % let it warm up a bit before rolling

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. do the initial plotting
         if X.mocap.doSimplePlot,
             %figure(11)
             h=findobj(gcf,'tag','markers');
             delete(h)

             plot(goodHandMarkers(:,1), goodHandMarkers(:,2),'r.','tag','markers','markersize',20);
             plot(goodHeadMarkers(:,1), goodHeadMarkers(:,2),'.','tag','markers','markersize',20);

             %plot(X.mocap.markerPosition(X.mocap.markers.head,1),X.mocap.markerPosition(X.mocap.markers.head,2),'.','tag','markers','markersize',20)
             %plot(X.mocap.markerPosition(X.mocap.markers.rightHand,1),X.mocap.markerPosition(X.mocap.markers.rightHand,2),'r.','tag','markers','markersize',20)
      
             set(gca, 'YLim', [-4 4]);
             set(gca, 'XLim', [-4 4]);
         end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. find the arm, head, nearest points on the walls and plot them 
        if ~isempty(goodMarkerIds)
            
            % find head and hand locations
            % todo: implement John's more robust head positioner
            handCentroid = median(goodHandMarkers(:,1:3));
            headCentroid = median(goodHeadMarkers(:,1:3));
            %headCentroid = median(X.mocap.markerPosition(find(goodMarkerIds == X.mocap.markers.head),1:3));
            
            % find the nearest wall and the nearest point on that wall to the
            % hand
            [nearestPoints, distances] = X.am.findNearestPoints(handCentroid);
            closestDistanceHand = min(distances(:));
            [closestWallIdHand closestMarkerIdHand] = find(distances == closestDistanceHand);
            closestWallPointHand = nearestPoints{closestMarkerIdHand(1)}(closestWallIdHand(1),:);
            
            [nearestPoints, distances] = X.am.findNearestPoints(headCentroid);
            closestDistanceHead = min(distances(:));
            [closestWallIdHead closestMarkerIdHead] = find(distances == closestDistanceHead);
            closestWallPointHead = nearestPoints{closestMarkerIdHead(1)}(closestWallIdHead(1),:);
            
            
            if length(closestWallIdHand)>1 % at some corners, it will find two points here and go haywire
                closestWallIdHand = closestWallIdHand(1); % arbitrarily choose the first one
                closestMarkerIdHand = closestMarkerIdHand(1); % same thing here
            end
            
            if length(closestWallIdHead)>1 % at some corners, it will find two points here and go haywire
                closestWallIdHead = closestWallIdHead(1); % arbitrarily choose the first one
                closestMarkerIdHead = closestMarkerIdHead(1); % same thing here
            end
            
            h=findobj(gcf,'tag','closestWall');
            delete(h)
            g=findobj(gcf,'tag','closestWallNeighbors');
            delete(g)
            len = length(X.am.mazeWalls);
            for n=1:len
                if n==closestWallIdHand         
                    if ~isempty(X.am.hasNeighbors{n})
                        for m=1:length(X.am.hasNeighbors{n})
                            line(X.am.mazeWalls(X.am.hasNeighbors{n}(m),1:2), X.am.mazeWalls(X.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.9 .5 .5], 'tag', 'closestWallNeighbors');
                        end
                    end
                end
                
                if n==closestWallIdHead
                    if ~isempty(X.am.hasNeighbors{n})
                        for m=1:length(X.am.hasNeighbors{n})
                            line(X.am.mazeWalls(X.am.hasNeighbors{n}(m),1:2), X.am.mazeWalls(X.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.5 .5 .9], 'tag', 'closestWallNeighbors');
                        end
                    end
                end
            end
            
            % plot the line from the hand to the nearest wall point
            h=findobj(gcf,'tag','wallDistanceBeamHand');
            delete(h)
            plot([handCentroid(1) closestWallPointHand(1)],[handCentroid(2) closestWallPointHand(2)], 'r', 'tag','wallDistanceBeamHand')
            % plot the line from the head to the nearest wall point
            h=findobj(gcf,'tag','wallDistanceBeamHead');
            delete(h)
            plot([headCentroid(1) closestWallPointHead(1)],[headCentroid(2) closestWallPointHead(2)], 'b', 'tag','wallDistanceBeamHead')

        end
        
        
        
        
        
    end
    frameNumber = frameNumber+1;

end