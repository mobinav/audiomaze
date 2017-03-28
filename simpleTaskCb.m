function simpleTaskCb
% simpleTaskCb callback function that is the main loop of the simpleTask 
% implementation of the audiomaze

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 0. initialize variables
    % the 'everything' structure
    global X
    
    % to count frames
    persistent frameNumber 
    
    % for checking whether or not we passed through a wall
    persistent isInWall
    
    % if we want to use the last good marker data to fill in bad markers
    persistent lastMarkers lastMarkerWasFresh acceptableMarkerAge 
    
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
   
    % moving average filters and banks for local average
    persistent avB velocityState
    filtLength = 100;
    
    % differential filter for finding velocity
    persistent diffB 
    
    % flag for whether or not we hit the end
    persistent hasStarted
    
    % flag for whether or not we can play the goal sound
    persistent canFlourish

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
        hasStarted = 0;
        canFlourish = 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 0. keep track of time
    timeIs = lsl_local_clock(X.LSL.lib);
    timeDiff = timeIs-timeWas;
    X.timeTotal = X.timeTotal+timeDiff;
    timeWas = timeIs;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. if this is the first frame, play the bell sound
    if frameNumber == 0
        X.LSL.MaxMSP.play_flourish(3, 'foo')
         HEDtag = 'Stimulus/Feedback,Stimulus/Auditory/StartBell,Filename/start_bell.wav';
         X.LSL.emitHEDtag(HEDtag, timeIs);
    end    

    % default 
    valueToSendHand = 999;
    valueToSendHead = 999;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2. get the latest phasespace input
    
    % pull the newest sample and organize the data
    % phasespace native coordinates are  'x' = N, 'y' = up, 'z' = E
    %   NB, this holds after recalibration march 2017. Prior to that x&z
    %   may have been swapped, e.g. if alignment done in different order?
    %   alignment method: origin, North mark, West mark
    
    % we use two strategies to protect from missing markers
    %   1) each LSL chunk has all samples since last call--if our maze
    %   cycle time is ~20ms, that should be about 9 samples. Previously, we
    %   used only the most recent sample. Instead, find the most recent
    %   'good' sample, if any -- at best an occasional gain
    %   2) keep track of markers that were good the last maze frame and use
    %   these to 'fill in' any markers missing from this frame
    goodHandMarkers=[];
    goodHeadMarkers=[];
    [sample, stamps] = X.LSL.phasespace.inlet.pull_chunk();

    if ~isempty(sample)    
        frameNumber = frameNumber+1;
        %here we convert phasespace coords to a more conventional system
        %where X = East, Y = North, Z = up--makes most sense sitting in control room
        
        if 1,
            % 1) pick the last good observation for each marker within this chunk
            %(an edge case, since it only helps when the
            %dropout occurs during the chunk, which is probably rare?)
            ys = sample(1:4:end-1,:); %N
            zs = sample(2:4:end-1,:); %up
            xs = sample(3:4:end-1,:); %E
            conf = sample(4:4:end-1,:);
            
            goodObservation = sample(4:4:end-1,:) ~= -1; %marker 'confidence' if = -1, it's missing
            [nMarkers, nSamples] = size(goodObservation);
            idx = ones(nMarkers, 1) * [1:nSamples];
            lastGoodObs = max(goodObservation .* idx, [], 2);
            lastGoodObs(lastGoodObs==0) = 1;
            lastGoodObsIndex = sub2ind([nMarkers, nSamples], 1:nMarkers, lastGoodObs');
            xs = xs(lastGoodObsIndex);
            ys = ys(lastGoodObsIndex);
            zs = zs(lastGoodObsIndex);
            conf = conf(lastGoodObsIndex);
        else %simple--just take last sample
            ys = sample(1:4:end-1,end); %N
            zs = sample(2:4:end-1,end); %up
            xs = sample(3:4:end-1,end); %E
            conf = sample(4:4:end-1,end);
            nMarkers = length(ys);
        end

        %X.mocap.markerPosition = [ys, xs, zs, conf];
        %March 22, 2017 we recalibrated and it seems to have changed the phase space coords!
        X.mocap.markerPosition = [xs(:) ys(:) zs(:) conf(:)]; %nmarker x coord
        
        %store last markers to provide some redundancy from dropouts
        %initialize (first time only)
        if isempty(lastMarkers)
            lastMarkers = X.mocap.markerPosition;
            lastMarkerWasFresh = frameNumber * ones(nMarkers,1);
            acceptableMarkerAge = 5; %older than five frames is marked as stale
        end
        
        %we can use last markers to fill in missing markers (so long as
        %last markers are also good and fresh)
        badCurrentMarkerIds = (X.mocap.markerPosition(:,4) < 0); %missing markers in current chunk
        %invalidate stale lastMarkers
        lastMarkers( (frameNumber-lastMarkerWasFresh)>acceptableMarkerAge, 4) = -999;
        %replace current bad markers with fresh history
        goodLastMarkerIds = (lastMarkers(:,4) >=0 );
        replaceableMarkers = badCurrentMarkerIds & goodLastMarkerIds;
        X.mocap.markerPosition(replaceableMarkers,:) = lastMarkers(replaceableMarkers,:);
        
        %update lastMarkers with all good markers from this sample
        lastMarkers(~badCurrentMarkerIds,:) =  X.mocap.markerPosition(~badCurrentMarkerIds,:);
        lastMarkerWasFresh(~badCurrentMarkerIds) = frameNumber;
        
        %collect all valid hand and head markers
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
        
    end
    
    % find head and hand locations
    % default to last good position, in case the whole thing is missing
    % todo: implement John's more robust head positioner
    if frameNumber > 1
        if ~isempty(goodHandMarkers)% && frameNumber ~= 0
            handCentroid = nanmedian(goodHandMarkers(:,1:3),1);
        else
            handCentroid = lastHandCentroid;
            fprintf(2,'NoHand\n');
        end

        if ~isempty(goodHeadMarkers) %&& frameNumber ~=0
            headCentroid = nanmedian(goodHeadMarkers(:,1:3),1); %TODO more robust head center
            % velocity is the difference of the magnitude of the xy parts
            % of the head centroid, should always be positive
            velocity = abs(filter(diffB,1, [norm(lastHeadCentroid(1:2)) norm(headCentroid(1:2))])/timeDiff);
            lastVelocity = velocity;
        else
            headCentroid = lastHeadCentroid;
            velocity = lastVelocity;
            fprintf(2,'NoHead\n');
        end

       % record the absolute value of velocity for later averaging
 %      if ~isempty(X.velocityFile)
 %          fprintf(X.velocityFile, '%f, ', velocity(end));
 %      end

        % N point moving average fiter
    %     velocityState(2:end) = velocityState(1:end-1);
    %     velocityState(1) = velocity(end);
    %     localAverageVelocity = filter(avB, 1, velocityState);

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

        if frameNumber >= 5 % let it warm up a bit before rolling

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % 4. find the arm, head, nearest points on the walls and plot them 
            
            if ~isempty(goodHandMarkers) || ~isempty(goodHeadMarkers)
                goodMarkerIds = (X.mocap.markerPosition(:,4) >= 0);
                fprintf(' %d', sum(goodMarkerIds))

                % do the initial plotting
                if X.mocap.doSimplePlot,
                    h=findobj(gcf,'tag','markers');
                    delete(h)
                    if ~isempty(goodHandMarkers),
                        plot(goodHandMarkers(:,1), goodHandMarkers(:,2),'r.','tag','markers','markersize',20);
                    else
                        plot(handCentroid(1),handCentroid(2),'mo','tag','markers','markersize',16)
                    end
                    
                    if ~isempty(goodHeadMarkers),
                        plot(goodHeadMarkers(:,1), goodHeadMarkers(:,2),'.','tag','markers','markersize',20);
                    else
                        plot(headCentroid(1),headCentroid(2),'co','tag','markers','markersize',16)
                    end
                    set(gca, 'YLim', [-4 4]);
                    set(gca, 'XLim', [-4 4]);
                end;
            end
            
            % find the nearest wall and the nearest point on that wall to the
            % hand
            [nearestPoints, distances] = X.am.findNearestPoints(handCentroid);
            closestDistanceHand = min(distances(:));
            [closestWallIdHand closestMarkerIdHand] = find(distances == closestDistanceHand);
            if length(closestWallIdHand)>1 % at some corners, it will find two points here and go haywire
                closestWallIdHand = closestWallIdHand(1); % arbitrarily choose the first one
                closestMarkerIdHand = closestMarkerIdHand(1); % same thing here
            end
            closestWallPointHand = nearestPoints{closestMarkerIdHand(1)}(closestWallIdHand(1),:);
            
            %head
            [nearestPoints, distances] = X.am.findNearestPoints(headCentroid);
            closestDistanceHead = min(distances(:));
            [closestWallIdHead closestMarkerIdHead] = find(distances == closestDistanceHead);
            if length(closestWallIdHead)>1 % at some corners, it will find two points here and go haywire
                closestWallIdHead = closestWallIdHead(1); % arbitrarily choose the first one
                closestMarkerIdHead = closestMarkerIdHead(1); % same thing here
            end
            closestWallPointHead = nearestPoints{closestMarkerIdHead(1)}(closestWallIdHead(1),:);


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
            plot(projectedAudioPointHand(1), projectedAudioPointHand(2),'ro', 'tag','audio_point', 'markersize',12, 'linewidth', 3);
            plot(projectedAudioPointHead(1), projectedAudioPointHead(2),'bo', 'tag','audio_point', 'markersize',12, 'linewidth', 3);

            % compute the angle for the audio engine
%             handAzimuth = rad2deg(atan2(projectedAudioPointHand(1), projectedAudioPointHand(2))); 
%             headAzimuth = rad2deg(atan2(projectedAudioPointHead(1), projectedAudioPointHead(2)));
% Check: Atan should be y,x, no?
            handAzimuth = rad2deg(atan2(projectedAudioPointHand(2), projectedAudioPointHand(1))); 
            headAzimuth = rad2deg(atan2(projectedAudioPointHead(2), projectedAudioPointHead(1))); 


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
                            title(sprintf('hand left wall %d %1.3f', X.inWallCntHand, X.totalTimeInWallHand));
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
                            title(sprintf('head left wall %d %1.3f', X.inWallCntHead, X.totalTimeInWallHead));
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
                            line(X.am.mazeWalls(closestWallIdHand,1:2), X.am.mazeWalls(closestWallIdHand,3:4), 'linewidth', 10, 'color','r', 'tag', 'handCrossedWall');
                            %break; % got one, no need to continue
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
                            line(X.am.mazeWalls(closestWallIdHead,1:2), X.am.mazeWalls(closestWallIdHead,3:4), 'linewidth', 10, 'color','b--', 'tag', 'headCrossedWall');
                            %break; % got one, no need to continue
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
                 figure(X.am.fig_handle);
                 title(sprintf('%1.3f %1.3f', closestDistanceHand, X.mazeinfo.handProximityThresh));
                if  closestDistanceHand > X.mazeinfo.handProximityThresh
                    valueToSendHand = 999;

                    % here we have just left near wall zone, reset flags and send
                    % HED marker
                    if isNearWallHand == 1;
                        X.totalTimeNearWallHand = X.totalTimeNearWallHand + timeNearWallHand;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandNear/Offset/Duration/%1.4f,Stimulus/Auditory/WallSound/HandNear/Offset/TotalDuration/%1.4f,',timeNearWallHand, X.totalTimeNearWallHand);
                        X.LSL.emitHEDtag(HEDtag, timeIs);
                        isNearWallHand = 0;
                        timeNearWallHand = 0;
                    end

                    % same, but for in wall
                    if isTouchingWallHand == 1;
                        X.totalTimeTouchingWallHand = X.totalTimeTouchingWallHand + timeTouchingWallHand;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandAlarm/Offset/Duration/%1.4f,Stimulus/Auditory/WallSound/HandAlarm/Offset/TotalDuration/%1.4f,',timeTouchingWallHand, X.totalTimeTouchingWallHand);
                        X.LSL.emitHEDtag(HEDtag, timeIs);
                        isTouchingWallHand = 0;
                        timeTouchingWallHand = 0;
                    end

                % we are now near the wall, possible in it or through it
                else
                    valueToSendHand = (closestDistanceHand/X.mazeinfo.handProximityThresh)^1;

                    % first frame near wall
                    if isNearWallHand == 0
                        X.nearWallCntHand = X.nearWallCntHand+1;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandNear/Onset/TouchCount/%d',X.nearWallCntHand);
                        X.LSL.emitHEDtag(HEDtag, timeIs); 
                    end

                    % do this always if near a wall
                    isNearWallHand = 1;
                    timeNearWallHand = timeNearWallHand+timeDiff;

                    % check to see if lingering near a wall, and switch to
                    % alarm if so
                    if timeNearWallHand > X.nearWallAccumThresh
                        X.lingeringWallCntHand = X.lingeringWallCntHand+1;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandAlarm/Onset/LingerCount/%d',X.lingeringWallCntHand);
                        X.LSL.emitHEDtag(HEDtag, timeIs);
                        valueToSendHand = 0;
                    end

                    % wall alarm is sounding
                    if 1-valueToSendHand > X.hand_in_wall_prox && timeNearWallHand <= X.nearWallAccumThresh

                        % first frame touching wall
                        if isTouchingWallHand == 0
                            X.touchingWallCntHand = X.touchingWallCntHand+1;
                            HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandAlarm/Onset/TouchCount/%d',X.touchingWallCntHand);
                            X.LSL.emitHEDtag(HEDtag, timeIs);
                        end

                        % do this always if touching a wall
                        isTouchingWallHand = 1;
                        timeTouchingWallHand = timeTouchingWallHand+timeDiff;
                    end
                end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 8. determine if head is touching or alarming
                if  closestDistanceHead > X.mazeinfo.headProximityThresh
                    valueToSendHead = 999;

                    % here we have just left near wall zone, reset flags and send
                    % HED marker (TODO)
                    if isNearWallHead == 1;
                        X.totalTimeNearWallHead = X.totalTimeNearWallHead + timeNearWallHead;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HeadNear/Offset/Duration/%1.4f,Stimulus/Auditory/WallSound/HeadNear/Offset/TotalDuration/%1.4f,',timeNearWallHead, X.totalTimeNearWallHead);
                        X.LSL.emitHEDtag(HEDtag, timeIs);
                        isNearWallHead = 0;
                        timeNearWallHead = 0;
                    end

                    % same, but for in wall
                    if isTouchingWallHead == 1;
                        X.totalTimeTouchingWallHead = X.totalTimeTouchingWallHead + timeTouchingWallHead;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HeadAlarm/Offset/Duration/%1.4f,Stimulus/Auditory/WallSound/HeadAlarm/Offset/TotalDuration/%1.4f,',timeTouchingWallHand, X.totalTimeTouchingWallHand);
                        X.LSL.emitHEDtag(HEDtag, timeIs);
                        isTouchingWallHead = 0;
                        timeTouchingWallHead = 0;
                    end

                % we are now near the wall, possibly in it
                else
                    valueToSendHead = (closestDistanceHead/X.mazeinfo.headProximityThresh)^1;

                    % first frame near wall
                    if isNearWallHead == 0
                        X.nearWallCntHead = X.nearWallCntHead+1;
                        HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HeadNear/Onset/TouchCount/%d',X.nearWallCntHead);
                        X.LSL.emitHEDtag(HEDtag, timeIs); 
                    end

                    % do this always when head is near wall
                    isNearWallHead = 1;
                    timeNearWallHead = timeNearWallHead+timeDiff;

                    % wall alarm is sounding
                    if 1-valueToSendHead > X.head_in_wall_prox

                        % first frame touching wall
                        if isTouchingWallHead == 0
                            X.touchingWallCntHead = X.touchingWallCntHead+1;
                            HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HeadAlarm/Onset/TouchCount/%d',X.touchingWallCntHead);
                            X.LSL.emitHEDtag(HEDtag, timeIs);
                        end

                        % do this always when head is touching wall
                        isTouchingWallHead = 1;
                        timeTouchingWallHead = timeTouchingWallHead+timeDiff;
                    end
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % 9. update plot, to show beams depending on state
            % plot the line from the hand to the nearest wall point
            figure(X.am.fig_handle);
            h=findobj(gcf,'tag','wallDistanceBeamHand');
            if ~isempty(h)
                delete(h)
            end
            if isNearWallHand,
                style='--'; lw = 1;
            elseif isTouchingWallHand,
                style='-'; lw = 2;
            else
                style=':'; lw = 1;
            end
            plot([handCentroid(1) closestWallPointHand(1)],[handCentroid(2) closestWallPointHand(2)], ['r' style], 'linewidth',lw, 'tag','wallDistanceBeamHand')
            
            % plot the line from the head to the nearest wall point
            h=findobj(gcf,'tag','wallDistanceBeamHead');
            if ~isempty(h)
                delete(h)
            end
            if isNearWallHead,
                style='--'; lw = 1;
            elseif isTouchingWallHead,
                style='-'; lw = 2;
            else
                style=':'; lw = 1;
            end
            plot([headCentroid(1) closestWallPointHead(1)],[headCentroid(2) closestWallPointHead(2)], ['b' style], 'linewidth',lw, 'tag','wallDistanceBeamHead')

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % 9. check to see if we got to the end
            for n=1:length(X.tokenReached)
                if X.tokenReached(n) == 0
                    dist = pdist([X.tokens.mocapLocs(n,:); headCentroid([1 2])], 'euclidean');
                    if dist<X.inTokenTol
                       % only plot this once
                       if X.tokenReached(n) == 0
                           plot(X.tokens.mocapLocs(n,1), X.tokens.mocapLocs(n,2), '.', 'color', [.9 .5 .5], 'markersize',30, 'linewidth', 3);
                       end
                        X.tokenReached(n) = 1;
                    end
                end
            end

            % check to see if we started, and returned
            if hasStarted == 1;
                dist = pdist([X.tokens.mocapLocs(1,:); headCentroid([1 2])], 'euclidean');
                if dist<X.inTokenTol
                    % only plot this once
                    if X.finished == 0;
                        plot(X.tokens.mocapLocs(1,1), X.tokens.mocapLocs(1,2), '.', 'color', [.5 .5 .9], 'markersize',30, 'linewidth', 3);
                    end
                    X.finished = 1;

                    % this is true if not all the end points were hit
                    if length(X.tokenReached(2:end)) ~= length(find(X.tokenReached(2:end))) && canFlourish == 1
                        X.LSL.MaxMSP.play_flourish(0, 'foo')
                        HEDtag = 'Stimulus/Feedback,Stimulus/Auditory/FinishedImperfect,Filename/fourish1.wav';
                        X.LSL.emitHEDtag(HEDtag, timeIs);
                        canFlourish = 0;
                        deduction = X.wallTouchDeduction * (X.touchingWallCntHand + X.lingeringWallCntHand);
                        X.bonus = X.bonus - deduction;
                        if X.bonus < 0
                            X.bonus = 0;
                        end
    %                     disp('Bonus = 1.2%f', X.bonus);
                        stop_maze();

                    else
                        if canFlourish == 1
                            X.LSL.MaxMSP.play_flourish(1, 'foo')
                            HEDtag = 'Stimulus/Feedback,Stimulus/Auditory/FinishedPerfect,Filename/fourish2.wav';
                            X.LSL.emitHEDtag(HEDtag, timeIs);
                            deduction = X.wallTouchDeduction * (X.touchingWallCntHand + X.lingeringWallCntHand);
                            X.bonus = X.bonus - deduction;
                            if X.bonus < 0
                                X.bonus = 0;
                            end
                            if X.bonus == 1.0
                                pause(4.75)
                                X.LSL.MaxMSP.play_flourish(2, 'foo')
                                HEDtag = 'Stimulus/Feedback,Stimulus/Auditory/FinishedPerfectFullBonus,Filename/endgame.wav';
                                X.LSL.emitHEDtag(HEDtag, timeIs);
                            end
                            canFlourish = 0;
                            stop_maze();

                        end
                    end
                end
            end
            % check to see if we left the first square yet
            if hasStarted == 0 && headCentroid([1]) ~= [0] && headCentroid([2]) ~= [0]; % this is only true before the ps is active
                dist = pdist([X.tokens.mocapLocs(1,:); headCentroid([1 2])], 'euclidean');
                if dist>X.outTokenTol

                    % only plot this once
                    if hasStarted == 0
                         plot(X.tokens.mocapLocs(1,1), X.tokens.mocapLocs(1,2), 'o', 'color', [.5 .5 .9], 'markersize',10, 'linewidth', 3);
                    end  
                    hasStarted = 1;

                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % 10. send events to the audio engine and emit behavioral data    

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
            X.LSL.MaxMSP.send_hand_proximity(valueToSendHand, handAzimuth, 'wallSound');
            X.LSL.MaxMSP.send_headwall(valueToSendHead, headAzimuth, 'wallSound');

            % emit the behavioral data for this frame
            frameData = [headCentroid, handCentroid, headAzimuth, handAzimuth, closestWallPointHead, closestWallPointHand];
            X.LSL.emitBehaviorFrame(frameData, timeIs);

        end % if frameNumber > 2


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 11. finish by getting ready for the next frame
        lastHeadCentroid = headCentroid;
        lastHandCentroid = handCentroid;
        
       
    end
 
    
    % for debugging:
%     if(frameNumber == 10)  
%         stop_maze();
%     end
end