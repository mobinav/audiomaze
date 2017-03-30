function simpleTaskCb
% simpleTaskCb callback function that is the main loop of the simpleTask
% implementation of the audiomaze

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. initialize variables
% the 'everything' structure
global X

persistent lastS %track of prior hand/head state (in wall, etc)

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
%     persistent isNearWallHand isTouchingWallHand
%     persistent timeNearWallHand timeTouchingWallHand
%     persistent isNearWallHead isTouchingWallHead
%     persistent timeNearWallHead timeTouchingWallHead
%     persistent timeInWallHand timeInWallHead

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
    lastS.hand.wallId = 0;
    lastS.hand.centroid = [0 0 0];
    lastS.head.wallId = 0;
    lastS.head.centroid = [0 0 0];
    
    %         lastWallIdHead = 0;
    %         lastWallIdHand = 0;
    %         lastHeadCentroid = [0 0 0];
    %         lastHandCentroid = [0 0 0];
    lastVelocity = 0;
    isInWall = 0;
    headCrossed = 0;
    handCrossed = 0;
    timeWas = lsl_local_clock(X.LSL.lib);
    %         isNearWallHand = 0;
    %         isTouchingWallHand = 0;
    %         timeNearWallHand = 0;
    %         timeTouchingWallHand = 0;
    %         isNearWallHead = 0;
    %         isTouchingWallHead = 0;
    %         timeNearWallHead = 0;
    %         timeTouchingWallHead = 0;
    %         timeInWallHand = 0;
    %         timeInWallHead = 0;
    velocityState = zeros(1,filtLength);
    avB = .1*ones(1,10);
    diffB = [1 -1];
    hasStarted = 0;
    canFlourish = 1;
    
    %initialize wallTouchState
    blank.numProximityTouches = 0;
    blank.numWallTouches = 0;
    blank.numThroughWall = 0;
    blank.proximityDuration = 0;
    blank.totalProxmityDuration = 0;
    blank.wallDuration = 0;
    blank.totalWallDuration = 0;
    X.wallTouchScores.hand = blank;
    X.wallTouchScores.head = blank;
    clear blank
    %copy over some needed values
    X.mazeinfo.hand.proximityThresh = X.mazeinfo.handProximityThresh;
    X.mazeinfo.hand.in_wall_prox    = X.hand_in_wall_prox;
    X.mazeinfo.head.proximityThresh = X.mazeinfo.headProximityThresh;
    X.mazeinfo.head.in_wall_prox    = X.head_in_wall_prox;
    
end

%set up our current state vector, make it easier to iterate head/hand
B.goodMarkers = [];
S.hand = B;
S.head = B;

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

frameNumber = frameNumber+1;
[sample, stamps] = X.LSL.phasespace.inlet.pull_chunk();

if ~isempty(sample)
    %convert phasespace coords to a more conventional system
    %where X = East, Y = North, Z = up--makes most sense sitting in control room
    %phasespace oriented to x=north, y=up, z=east
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
    
    %% collect all valid hand and head markers
    % TODO: this could be made more robust e.g. by using a rigid body
    %   model that is updated whenever all markers are visible (or at
    %   start during a calibration?).
    %TODO factorize
    cnt=1;
    for n=1:length(X.mocap.markers.rightHand)
        if X.mocap.markerPosition(X.mocap.markers.rightHand(n),4)>0
            S.hand.goodMarkers(cnt,:) = X.mocap.markerPosition(X.mocap.markers.rightHand(n),:);
            cnt=cnt+1;
        end
    end
    cnt=1;
    for n=1:length(X.mocap.markers.head)
        if X.mocap.markerPosition(X.mocap.markers.head(n),4)>0
            S.head.goodMarkers(cnt,:) = X.mocap.markerPosition(X.mocap.markers.head(n),:);
            cnt=cnt+1;
        end
    end
end %if sample

%% find head and hand locations
% default to last good position, in case the whole thing is missing
% todo: implement John's more robust head positioner
if frameNumber > 1
    for part = {'hand','head'},
        if ~isempty(S.(part).goodMarkers),
            S.(part).centroid = nanmedian(S.(part).goodMarkers(:,1:3),1);
        else
            S.(part).centroid = lastS.(part).centroid;
            fprintf(2,'No %s\n', part);
        end
    end
    
    %%
    if frameNumber >= 5 % let it warm up a bit before rolling
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. find the arm, head, nearest points on the walls and plot them
        
        if ~isempty(S.hand.goodMarkers) || ~isempty(S.hand.goodMarkers)
            goodMarkerIds = (X.mocap.markerPosition(:,4) >= 0);
            fprintf(' %d', sum(goodMarkerIds))
            
            % do the initial plotting
            if X.mocap.doSimplePlot,
                h=findobj(gcf,'tag','markers');
                delete(h)
                
                if ~isempty(S.hand.goodMarkers),
                    plot(S.hand.goodMarkers(:,1), S.hand.goodMarkers(:,2),'r.','tag','markers','markersize',20);
                else
                    plot(S.hand.centroid(1),S.hand.centroid(2),'mo','tag','markers','markersize',16)
                end
                
                if ~isempty(S.head.goodMarkers),
                    plot(S.head.goodMarkers(:,1), S.head.goodMarkers(:,2),'.','tag','markers','markersize',20);
                else
                    plot(S.head.centroid(1),S.head.centroid(2),'co','tag','markers','markersize',16)
                end
                set(gca, 'YLim', [-4 4]);
                set(gca, 'XLim', [-4 4]);
            end;
        end
        
        % find the nearest wall and the nearest point on that wall to the
        for part = {'hand','head'},
            [nearestPoints, distances] = X.am.findNearestPoints(S.(part).centroid);
            S.(part).closestDistance = min(distances(:));
            [S.(part).closestWallId, S.(part).closestMarkerId] = find(distances == S.(part).closestDistance);
            if length(S.(part).closestWallId)>1 % at some corners, it will find two points here and go haywire
                S.(part).closestWallId   = S.(part).closestWallId(1); % arbitrarily choose the first one
                S.(part).closestMarkerId = S.(part).closestMarkerId(1); % same thing here
            end
            S.(part).closestWallPoint = nearestPoints{S.(part).closestMarkerId}(S.(part).closestWallId,:);
        end
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % JRI, time to simplify. Just find distance of hand from wall
        % point and dot with head to wall point vector--if it's through
        % the wall and pointing back, sign of dot will be negative (do
        % this in 2d). Ditto for head.
        %
        % then simple state: if distance <0 it is through.
        % if hand is through then head comes through, it'll lose the
        % throughness, so we'll need to latch the throughness, perhaps?
        %
        %we can implement 'infinite through' behavior easily--if it's
        %negative, call the valueToSend = 0;
        
        % find distance and assign MAX control value as well as state
        for part = {'hand','head'},
            handToWall = S.hand.centroid(1:2) - S.(part).closestWallPoint;
            headToWall = S.head.centroid(1:2) - S.(part).closestWallPoint;
            crossed = sign(dot(handToWall, headToWall));
            S.(part).crossedWall = crossed < 0;
            S.(part).closestDistance = S.(part).closestDistance * crossed; %becomes negative if crossed over
            %check if closestDistanceHand ~ norm(handToWall)
            if S.(part).crossedWall, %if crossed through, we don't care how far
                S.(part).valueToSend = 0; %implements 'infinite thickness wall'
                S.(part).inProximity = true;
                S.(part).inWall      = true;
            else
                if S.(part).closestDistance > X.mazeinfo.(part).proximityThresh, %away from wall
                    S.(part).valueToSend = 999;
                    handInProximity = false;
                else %near wall--in proximity and possibly in wall
                    S.(part).valueToSend = (S.(part).closestDistance/X.mazeinfo.(part).proximityThresh)^1;
                    S.(part).inProximity = true;
                    if (1-valueToSendHand) > X.hand_in_wall_prox,
                        S.(part).inWall = true;
                    else
                        S.(part).inWall = false;
                    end
                end
            end %if crossed wall
        end %part loop
        
        isInWall = S.hand.crossedWall | S.head.crossedWall;
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        handAzimuth = -rad2deg(atan2(projectedAudioPointHand(1), projectedAudioPointHand(2)));
        headAzimuth = -rad2deg(atan2(projectedAudioPointHead(1), projectedAudioPointHead(2)));
        % need to sort this out, but is correct for now. Somehow MAX
        % and maze azimuths are inverses of each other. Not sure why
        % it's 1,2 instead of 2,1 (y,x)
        
        % we don't want head point to flip when head goes through wall,
        % so negate headAzimuth if through wall (I think that will
        % work)
        if headCrossed,
            headAzimuth = -headAzimuth;
        end
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % now make some decisions based on state transitions, emitting
        % proper markers and so on
        
        %stateVector = [handInProximity handInWall handCrossedWall headInProximity headInWall headCrossedWall];
        %changeState = xor(stateVector, lastS.stateVector);
        
        %HAND
        %TODO: loop
        % enter Proximity - increase count, start timer emit event
        if (S.hand.inProximity && ~lastS.hand.inProximity),
            X.wallTouchScores.hand.numProximityTouches = X.wallTouchScores.hand.numProximityTouches + 1;
            X.wallTouchScores.hand.proximityDuration = 0;
        end
        
        % leave Proximity - emit event (with timer value), reset timer
        
        % enter Wall
        
        % leave Wall
        
        % go through wall
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 6. determine if we are through the wall or not or if we got back
        C = handCentroid;
        D = headCentroid;
        
        % if we were in, check to see if we got out
        if isInWall
            timeInWallHand = timeInWallHand + timeDiff;
            keyboard
            
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
                    %title('in wall');
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
                        line(X.am.mazeWalls(closestWallIdHead,1:2), X.am.mazeWalls(closestWallIdHead,3:4), 'linewidth', 10, 'color','b','linestyle','--', 'tag', 'headCrossedWall');
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
            figure(X.am.fig_handle); %this profiled exceptionally slow--real?
            %title(sprintf('%1.3f %1.3f', closestDistanceHand, X.mazeinfo.handProximityThresh));
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
            style='-'; lw = 2;
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
            style='-'; lw = 2;
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
                        stop_maze(X);
                        
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
        X.LSL.MaxMSP.send_headwall(valueToSendHead, headAzimuth, 'wallSound'); %this profiles much slower, why?
        
        % emit the behavioral data for this frame
        %'headCentroid_x','headCentroid_y','headAzimuth','headDistance','closestWallPointHead_x','closestWallPointHead_y',...
        %'handCentroid_x','handCentroid_y','handAzimuth','handDistance','closestWallPointHand_x','closestWallPointHand_y'}
        frameData = [headCentroid(1:2), headAzimuth, closestDistanceHead, closestWallPointHead(1:2),...
            handCentroid(1:2), handAzimuth, closestDistanceHand, closestWallPointHand(1:2)];
        X.LSL.emitBehaviorFrame(frameData, timeIs);
        
    end % if frameNumber > 5
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 11. finish by getting ready for the next frame
%     lastHeadCentroid = headCentroid;
%     lastHandCentroid = handCentroid;
    
    %%% update title with informative info
    title(sprintf('hand: %3.3f %c, head: %3.3f %c (%s)',S.hand.valueToSend, fastif(S.hand.crossedWall,'W',' '),...
        S.head.valueToSend, fastif(S.head.crossedWall,'W',' '),fastif(isInWall,'In Wall','')),'fontsize',24);
    disp([isInWall S.hand.crossedWall S.head.crossedWall])
    
    % at END OF LOOP Store current state to compare in next frame
    % this'll be easiest (perhaps?) as a state vector that we can
    % xor?
    lastS = S;
    
end %if frameNumber > 1

% for debugging:
if (0 && X.mazeDebug && frameNumber == 10)
    %stop_maze();
    keyboard
end