% callback function that is the main loop of the simpleTask 
% implementation of the audiomaze
function simpleTaskCb

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 0. initialize variables
    % the 'everything' structure
    global X
    
    % to count frames
    persistent frameNumber 
    
    % for checking whether or not we passed through a wall
    persistent isInWall
    
    % if we want to use the last good marker data to fill in bad markers
    persistent lastMarkers
    
    % other persistent variables, previous frame data
    persistent lastWallIdHead lastWallIdHand lastHeadCentroid lastHandCentroid lastVelocity
    
    % for checking whether head or hand crossed first
    persistent headCrossed handCrossed
    
    % for keeping track of time
    persistent timeWas
    
    % action durations
    persistent isNearWallHand isTouchingWallHand 
    persistent timeNearWallHand timeTouchingWallHand 
    persistent isNearWallHead isTouchingWallHead 
    persistent timeNearWallHead timeTouchingWallHead 
    persistent timeInWallHand timeInWallHead
    
    % performance statistics
    persistent localAverageVelocity 
   
    % moving average filters and banks for local average
    persistent avB velocityState
    filtLength = 100;
    
    % differential filter for finding velocity
    persistent diffB 
    
    % flag for whether or not we hit the end
    persistent reachedEnd hasStarted
    
    % only true the first time, initiallize (nearly) everything here
    if isempty(frameNumber)
        frameNumber = 0;
        lastWallIdHead = 0;
        lastWallIdHand = 0;
        lastHeadCentroid = [0 0 0];
        lastHandCentroid = [0 0 0];
        lastVelocity = 0;
        isInWall = 0;
        headCrossed = 0;
        handCrossed = 0;
        timeWas = lsl_local_clock(X.LSL.lib);
        isNearWallHand = 0;
        isTouchingWallHand = 0;
        timeNearWallHand = 0;
        timeTouchingWallHand = 0;
        isNearWallHead = 0;
        isTouchingWallHead = 0;
        timeNearWallHead = 0;
        timeTouchingWallHead = 0;
        timeInWallHand = 0;
        timeInWallHead = 0;
        
        velocityState = zeros(1,filtLength);
        avB = .1*ones(1,10);
        diffB = [1 -1];
        reachedEnd = 0;
        hasStarted = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. keep track of time
    timeIs = lsl_local_clock(X.LSL.lib);
    timeDiff = timeIs-timeWas;
    X.timeTotal = X.timeTotal+timeDiff;
    timeWas = timeIs;
    
    % default 
    valueToSendHand = 999;
    valueToSendHead = 999;
    
    
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
        cnt=1;
        for n=1:length(X.mocap.markers.rightHand)
            if X.mocap.markerPosition(X.mocap.markers.rightHand(n),4)>0
                goodHandMarkers(cnt,:) = X.mocap.markerPosition(X.mocap.markers.rightHand(n),:);
                cnt=cnt+1;
            end
        end
        cnt=1;
        for n=1:length(X.mocap.markers.head)
            if X.mocap.markerPosition(X.mocap.markers.head(n),4)>0
                goodHeadMarkers(cnt,:) = X.mocap.markerPosition(X.mocap.markers.head(n),:);
                cnt=cnt+1;
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
    
    % default, in case the whole thing is missing
    headCentroid = lastHeadCentroid;
    handCentroid = lastHandCentroid;
    
    % find head and hand locations
    % todo: implement John's more robust head positioner
    % anyway, get the good markers and find the location
    if ~isempty(goodHandMarkers)
        handCentroid = nanmedian(goodHandMarkers(:,1:3));
    end
    
    if ~isempty(goodHeadMarkers)
        headCentroid = nanmedian(goodHeadMarkers(:,1:3));
    end
    
    % velocity is the difference of the magnitude of the xy parts of the
    % head centroid, should always be
    velocity = filter(diffB,1, [norm(lastHeadCentroid(1:2)) norm(headCentroid(1:2))])/timeDiff;
    
    % record the absolute value of velocity for later averaging
   if ~isempty(X.velocityFile)
        fprintf(X.velocityFile, '%f', velocity(end));
    end
    
    % N point moving average fiter
    velocityState(2:end) = velocityState(1:end-1);
    velocityState(1) = velocity(end);
    localAverageVelocity = filter(avB, 1, velocityState);
    lastVelocity = velocity;
    
    % plot it
%     if ~isempty(X.velocityPlot)
%        figure(X.velocityPlot)
%        plot((1-filtLength:0),localAverageVelocity, 'linewidth', 3)
%        axis([1-filtLength 0 -1 1])
%        title('Velocity profile', 'fontsize', 15);
%        xlabel('Frame Number', 'fontsize', 15);
%        ylabel('Velocity (meters per second)', 'fontsize', 15);
%        set(gca,'fontsize',14);
%     end
    
    if frameNumber >= 2;%5 % let it warm up a bit before rolling


        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. find the arm, head, nearest points on the walls and plot them 
        if ~isempty(goodMarkerIds)
            
            % do the initial plotting
            if X.mocap.doSimplePlot,
                h=findobj(gcf,'tag','markers');
                delete(h)
                
                plot(goodHandMarkers(:,1), goodHandMarkers(:,2),'r.','tag','markers','markersize',20);
                plot(goodHeadMarkers(:,1), goodHeadMarkers(:,2),'.','tag','markers','markersize',20);
                
                set(gca, 'YLim', [-4 4]);
                set(gca, 'XLim', [-4 4]);
            end;
        end
        

    
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

         % plot the nearest walls and their neighbors
%         h=findobj(gcf,'tag','closestWall');
%         delete(h)
%         g=findobj(gcf,'tag','closestWallNeighbors');
%         delete(g)
%         len = length(X.am.mazeWalls);
%         for n=1:len
%             if n==closestWallIdHand
%                 if ~isempty(X.am.hasNeighbors{n})
%                     for m=1:length(X.am.hasNeighbors{n})
%                         line(X.am.mazeWalls(X.am.hasNeighbors{n}(m),1:2), X.am.mazeWalls(X.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.9 .5 .5], 'tag', 'closestWallNeighbors');
%                     end
%                 end
%             end
%             
%             if n==closestWallIdHead
%                 if ~isempty(X.am.hasNeighbors{n})
%                     for m=1:length(X.am.hasNeighbors{n})
%                         line(X.am.mazeWalls(X.am.hasNeighbors{n}(m),1:2), X.am.mazeWalls(X.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.5 .5 .9], 'tag', 'closestWallNeighbors');
%                     end
%                 end
%             end
%         end
        
        % plot the line from the hand to the nearest wall point
        figure(X.am.fig_handle);
        h=findobj(gcf,'tag','wallDistanceBeamHand');
        if ~isempty(h)
            delete(h)
        end
        plot([handCentroid(1) closestWallPointHand(1)],[handCentroid(2) closestWallPointHand(2)], 'r', 'tag','wallDistanceBeamHand')
        % plot the line from the head to the nearest wall point
        h=findobj(gcf,'tag','wallDistanceBeamHead');
        if ~isempty(h)
            delete(h)
        end
        plot([headCentroid(1) closestWallPointHead(1)],[headCentroid(2) closestWallPointHead(2)], 'b', 'tag','wallDistanceBeamHead')

           
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % 5. compute the projected audio source point
        projectedAudioPointHand = X.am.findAudioProjection(headCentroid(1:2), closestWallPointHand);
        projectedAudioPointHead = X.am.findAudioProjection(headCentroid(1:2), closestWallPointHead);
        projectedAudioPointHand(3) = 0;
        projectedAudioPointHead(3) = 0;
                
        % plot
        figure(X.am.fig_handle);
        h=findobj(gcf,'tag','audio_point');
        if ~isempty(h)
            delete(h)
        end
        plot(projectedAudioPointHand(1), projectedAudioPointHand(2),'ro', 'tag','audio_point', 'markersize',30, 'linewidth', 3);
        plot(projectedAudioPointHead(1), projectedAudioPointHead(2),'bo', 'tag','audio_point', 'markersize',30, 'linewidth', 3);

        % compute the angle for the audio engine
        angleForInRoomHand = rad2deg(atan2(projectedAudioPointHand(1), projectedAudioPointHand(2))); 
        angleForInRoomHead = rad2deg(atan2(projectedAudioPointHead(1), projectedAudioPointHead(2))); 

                    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 6. determine if we are through the wall or not or if we got back   
        C = handCentroid;
        D = headCentroid;
      
        % if we were in, check to see if we got out
        if isInWall
            timeInWallHand = timeInWallHand + timeDiff;
            
            % the hand went accross first, so it needs to go back
            if handCrossed 
                %valueToSendHand = 0;    
                for n=1:length(X.am.hasNeighbors{lastWallIdHand})
                    A = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHand}(n),1:2:3);
                    B = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHand}(n),2:2:4);
                    
                    if whichSide(C, A, B) ~= whichSide(lastHandCentroid, A, B)
                        isInWall = 0;
                        X.totalTimeInWallHand = X.totalTimeInWallHand + timeInWallHand;
                        X.inWallCntHand = X.inWallCntHand+1;
                        timeInWallHand = 0;
                        handCrossed = 0;
                        figure(X.am.fig_handle)
                        title(sprintf('left wall %d %1.3f', X.inWallCntHand, X.totalTimeInWallHand));
                        g=findobj(gcf,'tag','handCrossedWall');
                        if ~isempty(g)
                            delete(g)
                        end
                        break;
                        %%%%%% out of wall hand HED marker goes here %%%%%%
                    end
                end
            end
            
            if headCrossed
                %valueToSendHead = 0;
                for n=1:length(X.am.hasNeighbors{lastWallIdHead})
                    A = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHead}(n),1:2:3);
                    B = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHead}(n),2:2:4);
                    
                    if whichSide(D, A, B) ~= whichSide(lastHeadCentroid, A, B)
                        isInWall = 0;
                        X.totalTimeInWallHead = X.totalTimeInWallHead + timeInWallHead;
                        X.inWallCntHead = X.inWallCntHead+1;
                        timeInWallHead = 0;
                        headCrossed = 0;
                        figure(X.am.fig_handle)
                        title(sprintf('left wall %d %1.3f', X.inWallCntHead, X.totalTimeInWallHead));
                        g=findobj(gcf,'tag','headCrossedWall');
                        if ~isempty(g)
                            delete(g)
                        end
                        break;
                        %%%%%% out of wall hand HED marker goes here %%%%%%
                    end
                end
            end
                
        end
        
        % if we were not in a wall, check to see if we are now
        if ~isInWall
            
            % check for hand crossing
            for n=1:length(X.am.hasNeighbors{closestWallIdHand})
                
                % cycle through connected wall endpoints and check
                A = X.am.mazeWalls(X.am.hasNeighbors{closestWallIdHand}(n), 1:2:3);
                B = X.am.mazeWalls(X.am.hasNeighbors{closestWallIdHand}(n), 2:2:4);
                
                % check if there is a wall between head and hand
                isInWall = doesIntersect(A,B,C,D);
                %%%% HED enter wall here

                if isInWall
                    figure(X.am.fig_handle)
                    title('in wall');
                    % check if hand or head crossed first
                    if whichSide(C, A, B) ~= whichSide(lastHandCentroid, A, B)
                        handCrossed = 1;
                        valueToSendHand = 0;
                        lastWallIdHand = closestWallIdHand; % keep track of this
                        % plot for now
                        g=findobj(gcf,'tag','handCrossedWall');
                        if ~isempty(g)
                            delete(g)
                        end
                        line(X.am.mazeWalls(closestWallIdHand,1:2), X.am.mazeWalls(closestWallIdHand,3:4), 'linewidth', 10, 'color','k', 'tag', 'handCrossedWall');
                        break; % got one, no need to continue
                    end
                    
                    if whichSide(D, A, B) ~= whichSide(lastHeadCentroid, A, B)
                        headCrossed = 1;
                        valueToSendHead = 0;
                        lastWallIdHead = closestWallIdHead; % keep track of this
                        % plot for now
                        g=findobj(gcf,'tag','headCrossedWall');
                        if ~isempty(g)
                            delete(g)
                        end
                        line(X.am.mazeWalls(closestWallIdHead,1:2), X.am.mazeWalls(closestWallIdHead,3:4), 'linewidth', 10, 'color','g', 'tag', 'headCrossedWall');
                        break; % got one, no need to continue
                    end
                end
            end
        end

        % have to check this again
        if isInWall && handCrossed
            valueToSendHand = 0;
        elseif isInWall && headCrossed
            valueToSendHead = 0;
        end
        
        if ~isInWall
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 7. determine if hand is touching or alarming
%             figure(X.am.fig_handle);
%             title(sprintf('%1.3f %1.3f', closestDistanceHand, X.handProximityThresh));
            if  closestDistanceHand > X.handProximityThresh
                valueToSendHand = 999;
                
                % here we have just left near wall zone, reset flags and send
                % HED marker (TODO)
                if isNearWallHand == 1;
                    X.totalTimeNearWallHand = X.totalTimeNearWallHand + timeNearWallHand;
                    isNearWallHand = 0;
                    timeNearWallHand = 0;
                end
                
                % same, but for in wall
                if isTouchingWallHand == 1;
                    X.totalTimeTouchingWallHand = X.totalTimeTouchingWallHand + timeTouchingWallHand;
                    isTouchingWallHand = 0;
                    timeTouchingWallHand = 0;
                end
                
            % we are now near the wall, possible in it or through it
            else
                valueToSendHand = (closestDistanceHand/X.handProximityThresh)^1;

                % first frame near wall
                if isNearWallHand == 0
                    X.nearWallCntHand = X.nearWallCntHand+1;
                    %%%%%%% HED marker emition
                end

                % do this always
                isNearWallHand = 1;
                timeNearWallHand = timeNearWallHand+timeDiff;

                % wall alarm is sounding
                if 1-valueToSendHand > X.hand_in_wall_prox

                    % first frame touching wall
                    if isTouchingWallHand == 0
                        X.touchingWallCntHand = X.touchingWallCntHand+1;
                        %%%%%%% HED marker emition
                    end

                    % do this always
                    isTouchingWallHand = 1;
                    timeTouchingWallHand = timeTouchingWallHand+timeDiff;
                end

            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % 8. determine if head is touching or alarming
            if  closestDistanceHead > X.headProximityThresh
                valueToSendHead = 999;
                
                % here we have just left near wall zone, reset flags and send
                % HED marker (TODO)
                if isNearWallHead == 1;
                    X.totalTimeNearWallHead = X.totalTimeNearWallHead + timeNearWallHead;
                    isNearWallHead = 0;
                    timeNearWallHead = 0;
                end
                
                % same, but for in wall
                if isTouchingWallHead == 1;
                    X.totalTimeTouchingWallHead = X.totalTimeTouchingWallHead + timeTouchingWallHead;
                    isTouchingWallHead = 0;
                    timeTouchingWallHead = 0;
                end
                
                
                
                % we are now near the wall, possible in it
            else
                valueToSendHead = (closestDistanceHead/X.headProximityThresh)^1;
                
                % first frame near wall
                if isNearWallHead == 0
                    X.nearWallCntHead = X.nearWallCntHead+1;
                    %%%%%%% HED marker emition
                end
                
                % do this always
                isNearWallHead = 1;
                timeNearWallHead = timeNearWallHead+timeDiff;
                
                % wall alarm is sounding
                if 1-valueToSendHead > X.head_in_wall_prox
                    
                    % first frame touching wall
                    if isTouchingWallHead == 0
                        X.touchingWallCntHead = X.touchingWallCntHead+1;
                        %%%%%%% HED marker emition
                    end
                    
                    % do this always
                    isTouchingWallHead = 1;
                    timeTouchingWallHead = timeTouchingWallHead+timeDiff;
                end
                
            end
            

        end
        
        % plot touch stats
%         figure(X.am.fig_handle)
%         title(sprintf('%d timeNearWallHand %1.3f %d %d timeTouchingWall %1.3f %d ', ...
%             isNearWallHand, timeNearWallHand, nearWallCntHand, ...
%             isTouchingWallHand, timeTouchingWallHand, touchingWallCntHand));


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 9. check to see if we got to the end
        if reachedEnd == 0
            dist = pdist([X.tokens.mocapLocs(2,:); headCentroid([1 2])], 'euclidean');
            if dist<X.inTokenTol
                reachedEnd = 1;
            end
        end
        
        
        % check to see if we started, and returned
        if hasStarted == 1;
            dist = pdist([X.tokens.mocapLocs(2,:); headCentroid([1 2])], 'euclidean');
            if dist<X.inTokenTol
                X.finished = 1;
                if reachedEnd == 0
                    X.LSL.MaxMSP.play_flourish(0, 'foo')
                else
                    X.LSL.MaxMSP.play_flourish(1, 'foo')
                end
            end
        end
        % check to see if we left the first square yet
        if hasStarted == 0;
            dist = pdist([X.tokens.mocapLocs(2,:); headCentroid([1 2])], 'euclidean');
            if dist>X.outTokenTol
                hasStarted = 1;
            end
        end
        
        
        % determine the pitch of the wall touch sound
        noiseFreq = 1;
        % we are near an outer wall
        if closestWallIdHand < 5
            noiseFreq = 1;
            % check if the hand is near the end of disconnected wall point
        elseif X.am.isPointFloating(closestWallPointHand)
            noiseFreq = 2;
        else
            noiseFreq = 3;
        end
        
        % send the values to the audio engine
        X.LSL.MaxMSP.send_noise_freq(noiseFreq, '');
        X.LSL.MaxMSP.send_hand_proximity(valueToSendHand, angleForInRoomHand, 'wallSound');
        X.LSL.MaxMSP.send_headwall(valueToSendHead, angleForInRoomHead, 'wallSound');


    end
    
    lastHeadCentroid = headCentroid;
    lastHandCentroid = handCentroid;
    frameNumber = frameNumber+1;

end