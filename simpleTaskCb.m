function simpleTaskCb
% simpleTaskCb callback function that is the main loop of the simpleTask
% implementation of the audiomaze

parts = {'hand','head'};
partColor.hand = 'r';  %plot colors for hand and head
partColor.head = 'b';

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
    X.performance.wallTouchScores.hand = blank;
    X.performance.wallTouchScores.head = blank;
    X.performance.maxEarning = 0;
    X.performance.earned = 0;
    X.performance.lost = 0;
    X.performance.foundAllTokens = false;
    X.performance.nFoundTokens = 0;
    clear blank
    %copy over some needed values
    X.mazeinfo.hand.proximityThresh = X.mazeinfo.handProximityThresh;
    X.mazeinfo.hand.in_wall_prox    = X.hand_in_wall_prox;
    X.mazeinfo.head.proximityThresh = X.mazeinfo.headProximityThresh;
    X.mazeinfo.head.in_wall_prox    = X.head_in_wall_prox;
end

%set up our current state vector, make it easier to iterate head/hand
clear B
B.goodMarkers = [];
B.centroid = [0 0 0];
B.closestDistance = inf;
B.closestWallId = [];
B.closestWallPoint = [];
B.closestMarkerId = [];
B.inProximity = false;
B.inWall = false;
B.crossedWall = false;
B.valueToSend = 999;
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
    for part = {'hand','head'}
        if ~isempty(S.(part{:}).goodMarkers)
            S.(part{:}).centroid = nanmedian(S.(part{:}).goodMarkers(:,1:3),1);
        else
            S.(part{:}).centroid = lastS.(part{:}).centroid;
            fprintf(2,'No %s\n', part{:});
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
            if X.mocap.doSimplePlot
                h=findobj(gcf,'tag','markers');
                delete(h)
                
                if ~isempty(S.hand.goodMarkers)
                    plot(S.hand.goodMarkers(:,1), S.hand.goodMarkers(:,2),'r.','tag','markers','markersize',20);
                else
                    plot(S.hand.centroid(1),S.hand.centroid(2),'mo','tag','markers','markersize',16)
                end
                
                if ~isempty(S.head.goodMarkers)
                    plot(S.head.goodMarkers(:,1), S.head.goodMarkers(:,2),'.','tag','markers','markersize',20);
                else
                    plot(S.head.centroid(1),S.head.centroid(2),'co','tag','markers','markersize',16)
                end
                set(gca, 'YLim', [-4 4]);
                set(gca, 'XLim', [-4 4]);
            end;
        end
        
        % find the nearest wall and the nearest point on that wall to the
        for part = {'hand','head'}
            [nearestPoints, distances] = X.am.findNearestPoints(S.(part{:}).centroid);
            S.(part{:}).closestDistance = min(distances(:));
            [S.(part{:}).closestWallId, S.(part{:}).closestMarkerId] = find(distances == S.(part{:}).closestDistance);
            if length(S.(part{:}).closestWallId)>1 % at some corners, it will find two points here and go haywire
                S.(part{:}).closestWallId   = S.(part{:}).closestWallId(1); % arbitrarily choose the first one
                S.(part{:}).closestMarkerId = S.(part{:}).closestMarkerId(1); % same thing here
            end
            S.(part{:}).closestWallPoint = nearestPoints{S.(part{:}).closestMarkerId}(S.(part{:}).closestWallId,:);
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
        for part = {'hand','head'}
            handToWall = S.hand.centroid(1:2) - S.(part{:}).closestWallPoint;
            headToWall = S.head.centroid(1:2) - S.(part{:}).closestWallPoint;
            crossed = sign(dot(handToWall, headToWall));
            S.(part{:}).crossedWall = crossed < 0;
            S.(part{:}).closestDistance = S.(part{:}).closestDistance * crossed; %becomes negative if crossed over
            %check if closestDistanceHand ~ norm(handToWall)
            %if crossed through, we don't care how far: implements 'infinite thickness wall'
            if S.(part{:}).crossedWall && X.infinteWalls
                S.(part{:}).valueToSend = 0;
                S.(part{:}).inProximity = true;
                S.(part{:}).inWall      = true;
            else
                if abs(S.(part{:}).closestDistance) > X.mazeinfo.(part{:}).proximityThresh %far away from wall, sounds off (abs needed in case infiniteWalls=false
                    S.(part{:}).valueToSend = 999;
                    S.(part{:}).inProximity = false;
                else %near wall--in proximity and possibly in wall
                    S.(part{:}).valueToSend = abs(S.(part{:}).closestDistance/X.mazeinfo.(part{:}).proximityThresh)^1;
                    S.(part{:}).inProximity = true;
                    if (1-valueToSendHand) > X.hand_in_wall_prox
                        S.(part{:}).inWall = true;
                    else
                        S.(part{:}).inWall = false;
                    end
                end
            end %if crossed wall
        end %part loop
        
        isInWall = S.hand.crossedWall | S.head.crossedWall;
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 5. compute the projected audio source point
        
        projectedAudioPointHand = X.am.findAudioProjection(S.head.centroid(1:2), S.hand.closestWallPoint);
        projectedAudioPointHead = X.am.findAudioProjection(S.head.centroid(1:2), S.head.closestWallPoint);
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
        if S.head.crossedWall
            headAzimuth = -headAzimuth;
        end
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 10. send events to the audio engine and emit behavioral data
        
        % determine the pitch of the wall touch sound
        noiseFreq = 1;
        % we are near an outer wall
        if S.hand.closestWallId < 5
            noiseFreq = 1;
            % check if the hand is near the end of disconnected wall point
        elseif X.am.isPointFloating(S.hand.closestWallPoint)
            noiseFreq = 2;
        else
            noiseFreq = 3;
        end
        
        % send the values to the audio engine
        X.LSL.MaxMSP.send_noise_freq(noiseFreq, '');
        X.LSL.MaxMSP.send_hand_proximity(S.hand.valueToSend, handAzimuth, 'wallSound');
        X.LSL.MaxMSP.send_headwall(S.head.valueToSend, headAzimuth, 'wallSound'); %this profiles much slower, why?
        
        % emit the behavioral data for this frame
        %'headCentroid_x','headCentroid_y','headAzimuth','headDistance','closestWallPointHead_x','closestWallPointHead_y',...
        %'handCentroid_x','handCentroid_y','handAzimuth','handDistance','closestWallPointHand_x','closestWallPointHand_y'}
        frameData = [headCentroid(1:2), headAzimuth, closestDistanceHead, closestWallPointHead(1:2),...
            handCentroid(1:2), handAzimuth, closestDistanceHand, closestWallPointHand(1:2)];
        X.LSL.emitBehaviorFrame(frameData, timeIs);
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % now make some decisions based on state transitions, emitting
        % proper markers and so on
        
        %stateVector = [handInProximity handInWall handCrossedWall headInProximity headInWall headCrossedWall];
        %changeState = xor(stateVector, lastS.stateVector);
        
        for part = {'hand','head'}
            % enter Proximity - increase count, start timer emit event
            if (S.(part{:}).inProximity && ~lastS.(part{:}).inProximity)
                X.wallTouchScores.(part{:}).numProximityTouches = X.wallTouchScores.(part{:}).numProximityTouches + 1;
                X.wallTouchScores.(part{:}).proximityDuration = timeIs; %hack: store start time here
                HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandProximity/Onset/TouchCount/%d',X.wallTouchScores.(part{:}).numProximityTouches);
                X.LSL.emitHEDtag(HEDtag, timeIs);
            end
            % leave Proximity - emit event (with timer value), reset timer
            if (~S.(part{:}).inProximity && lastS.(part{:}).inProximity)
                X.wallTouchScores.(part{:}).proximityDuration = timeIs - X.wallTouchScores.(part{:}).proximityDuration;
                X.wallTouchScores.(part{:}).totalProximityDuration = X.wallTouchScores.(part{:}).totalProximityDuration + X.wallTouchScores.(part{:}).proximityDuration;
                HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandProximity/Offset/Duration/%1.4f',X.wallTouchScores.(part{:}).proximityDuration);
                X.LSL.emitHEDtag(HEDtag, timeIs);
            end
            % enter Wall
            if (S.(part{:}).inWall && ~lastS.(part{:}).inWall)
                X.wallTouchScores.(part{:}).numWallTouches = X.wallTouchScores.(part{:}).numWallTouches + 1;
                X.wallTouchScores.(part{:}).wallDuration = timeIs; %hack: store start time here
                HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandWall/Onset/TouchCount/%d',X.wallTouchScores.(part{:}).numWallTouches);
                X.LSL.emitHEDtag(HEDtag, timeIs);
            end
            % leave Wall
            if (~S.(part{:}).inWall && lastS.(part{:}).inWall)
                X.wallTouchScores.(part{:}).wallDuration = timeIs - X.wallTouchScores.(part{:}).wallDuration;
                X.wallTouchScores.(part{:}).totalWallDuration = X.wallTouchScores.(part{:}).totalWallDuration + X.wallTouchScores.(part{:}).wallDuration;
                HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandProximity/Offset/Duration/%1.4f',X.wallTouchScores.(part{:}).wallDuration);
                X.LSL.emitHEDtag(HEDtag, timeIs);
            end
            % go through wall
            if (S.(part{:}).crossedWall && ~lastS.(part{:}).crossedWall)
                X.wallTouchScores.(part{:}).numThroughWall = X.wallTouchScores.(part{:}).numThroughWall + 1;
                HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandThroughWall/Onset/TouchCount/%d',X.wallTouchScores.(part{:}).numThroughWall);
                X.LSL.emitHEDtag(HEDtag, timeIs);
                line(X.am.mazeWalls(S.(part{:}).closestWallId,1:2), X.am.mazeWalls(S.(part{:}).closestWallId,3:4), 'linewidth', 10, 'color',partColor.(part{:}), 'tag', [part{:} 'CrossedWall']);
            end
            %return from going through wall
            if (~S.(part{:}).crossedWall && lastS.(part{:}).crossedWall)
                HEDtag = sprintf('Stimulus/Feedback,Stimulus/Auditory/WallSound/HandThroughWall/Offset');
                X.LSL.emitHEDtag(HEDtag, timeIs);
                delete(findobj(gcf,'tag',[part{:} 'CrossedWall']))
            end
        end %part loop
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 9. update plot, to show beams depending on state
        % plot the line from the hand to the nearest wall point
        figure(X.am.fig_handle);
        for part = {'hand','head'}
            delete(findobj(gcf,'tag',[part{:} 'WallDistanceBeam']));
            if S.(part{:}).inProximity
                style='-'; lw = 2;
            elseif S.(part{:}).inWall
                style='-'; lw = 3;
            else
                style=':'; lw = 1;
            end
            plot([S.(part{:}).centroid(1) S.(part{:}).closestWallPoint(1)],[S.(part{:}).centroid(2) S.(part{:}).closestWallPoint(2)], [partColor.(part{:}) style], 'linewidth',lw, 'tag',[part{:} 'WallDistanceBeam']) 
        end %part loop
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 9. check to see if we got to the maze end
        for n=1:length(X.tokenReached)
            if X.tokenReached(n) == 0
                dist = pdist([X.tokens.mocapLocs(n,:); S.head.centroid([1 2])], 'euclidean');
                if dist<X.inTokenTol
                    % only plot this once
                    if X.tokenReached(n) == 0
                        plot(X.tokens.mocapLocs(n,1), X.tokens.mocapLocs(n,2), '.', 'color', [.9 .5 .5], 'markersize',30, 'linewidth', 3);
                    end
                    X.tokenReached(n) = 1;
                end
            end
        end
        
        %% check to see if we have returned to end
        distToStart = pdist([X.tokens.mocapLocs(1,:); S.head.centroid([1 2])], 'euclidean');
        if hasStarted && distToStart < X.inTokenTol
            %we've finished!
            % only plot this once
            if X.finished == 0
                plot(X.tokens.mocapLocs(1,1), X.tokens.mocapLocs(1,2), '.', 'color', [.5 .9 .5], 'markersize',30, 'linewidth', 3); %green signifies end
            end
            X.finished = 1;
            
            %did we explore entire maze (or not?) --play appropriate ending
            %sound
            % depends if all the token points were hit
            X.performance.nFoundTokens = sum(X.tokenReached(2:end));
            X.performance.foundAllTokens = (X.perfornamce.nFoundTokens == length(X.tokenReached(2:end)));
            
            if X.performance.foundAllTokens && canFlourish == 1
                X.LSL.MaxMSP.play_flourish(1, 'FoundAllTokens')
                HEDtag = 'Stimulus/Feedback,Stimulus/Auditory/FinishedPerfect,Filename/fourish2.wav';
                X.LSL.emitHEDtag(HEDtag, timeIs);
                canFlourish = 0;
            else
                X.LSL.MaxMSP.play_flourish(0, 'FoundSomeTokens')
                HEDtag = 'Stimulus/Feedback,Stimulus/Auditory/FinishedImperfect,Filename/fourish1.wav';
                X.LSL.emitHEDtag(HEDtag, timeIs);
                canFlourish = 0;
            end
            
            %calculate bonus
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
            
            %% END HERE score and save
            finalizeScoring(X);
            stop_maze(X);
            %% END HERE
            
        end %we reached end
        
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
        % 11. finish by getting ready for the next frame
        
        %%% update title with informative info
        title(sprintf('hand: %3.3f %c, head: %3.3f %c (%s)',S.hand.valueToSend, fastif(S.hand.crossedWall,'W',' '),...
            S.head.valueToSend, fastif(S.head.crossedWall,'W',' '),fastif(isInWall,'In Wall','')),'fontsize',24);
        disp([isInWall S.hand.crossedWall S.head.crossedWall])
        
    end % if frameNumber > 5
      
    % at END OF LOOP Store current state to compare in next frame
    % this'll be easiest (perhaps?) as a state vector that we can
    % xor?
    lastS = S;
    
end %if frameNumber > 1

% for debugging:
if (1 && X.debugMaze && frameNumber == 10)
    disp('stopping after frame 10 for debugging')
    keyboard
end