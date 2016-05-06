function mr_maze_lsl
% main maze code--takes markers and calculates hand proximity to maze
% walls, sends messages to Max when near wall to play sound
%
% mr_maze version converted to use LSL
% 12/13, MM&JRI

%holdover from datariver days, we'll adapt it for our own purposes if
%necessary
global mr;

persistent wallProjectionLocation audioLocation nearWallAccumulator homingSoundTurnedOn 
noHeadCount=0;
lastHeadMarkerPosition = [0 0 0];
closestWallPointHand = [0 0];
closestDistanceHand = 1;
closestWallIdHand = 1;
closestWallPointHead = [0 0];
closestDistanceHead = 1;
closestWallIdHead = 1;
inWallId = 1;
isInWall = false;
wasInWall = false;
armCentroid = [0 0];
lastArmCentroid = [0 0];
isWallPointFloating = false;

%% start the beacon--from the door area of the lab (maze exit)
if mr.numberOfFramesInAccumulatedData > 5 %only run if we have at least four frames of phsasespace data?
    

    
    
    
    
    
    % target sound
%     if  isempty(homingSoundTurnedOn),
%         % evet-code-to-datariver control1 (angle) control2(azimuth)
%         % event_to_be returned_in_audioSend volume azimuth repeat on/off
%         % filename
%         %mr.LSL.MaxMSP.play_sound(3, 1, 1, 140, 95, 'beacon3'); %sound number 3, loop, from azimuth 135 degrees
%         %mr.LSL.MaxMSP.play_sound(0, 0, 0, 0, 0, 0); %? turn all off?
%         %disp('Will be replaced with LSL') % mr_write_buffer('/tmp/AudioSuite', 0, [0  0 0 3 110 135 1 1 3]');
%         %disp('Will be replaced with LSL') % mr_write_buffer('/tmp/AudioSuite', 0, [0  0 0 0 0 0 0 0 0]');
%         
%         homingSoundTurnedOn = true;
%         tic;
%     else
%         %mr.LSL.MaxMSP.play_sound(3, 0, 0, 135, 110, 'beacon3'); %sound number 3, loop, from azimuth 135 degrees
%     end;
% 
%     
%     if isempty(nearWallAccumulator)
%         nearWallAccumulator = 0;
%     end;
        
     % MM/JRI use first 4 sensors, which is defined as head in the montage
    %  Head marker is so important for localization, we're using four
    %  markers for redundancy. Find average of good ones
    
    
    % Revision by David Medine, 10/2015
    % take the new notion of a maze, and determine the nearest point on the
    % nearest wall -- then return that point
    



    % 11/13/2015 DEM
    % using lastHandMarkers to fill in 'bad' markers
%     currentHandMarkers = mr.mocap.markerPosition(mr.mocap.markers.rightHand,:); % all hand
    % just fingertips
     currentHandMarkers = mr.mocap.markerPosition(mr.mocap.markers.rightHand(1:4),:);  
     currentHandMarkers = [currentHandMarkers;mr.mocap.markerPosition(mr.mocap.markers.rightHand(6),:)];
     
    for n=1:length(currentHandMarkers)
        if currentHandMarkers(n, 1:2) == [0 0]
            currentHandMarkers(n,:) = mr.lastHandMarkers(n,:);
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %%% Added by Makoto %%%
    %%%%%%%%%%%%%%%%%%%%%%%
    % plot beam to the closest WallPoint
    goodHandMarkerId = find(mr.mocap.markerPosition(mr.mocap.markers.rightHand,3)> -10);
    if ~isempty(goodHandMarkerId),
        
        % find hand location
        armCentroid = median(currentHandMarkers);
        
        % find the nearest wall and the nearest point on that wall to the
        % hand
        [nearestPoints, distances] = mr.am.findNearestPoints(armCentroid);%(mr.mocap.markerPosition(mr.mocap.markers.rightHand,:));
        closestDistanceHand = min(distances(:));
        [closestWallIdHand closestMarkerIdHand] = find(distances == closestDistanceHand);
        closestWallPointHand = nearestPoints{closestMarkerIdHand(1)}(closestWallIdHand(1),:);
        

        
        if length(closestWallIdHand)>1 % at some corners, it will find two points here and go haywire
            closestWallIdHand = closestWallIdHand(1); % arbitrarily choose the first one
            closestMarkerIdHand = closestMarkerIdHand(1); % same thing here
        end
%         if 0,
%             armCentroid = mean(mr.mocap.markerPosition(mr.mocap.markers.rightHand(goodHandMarkerId),:));
%         else
%             armCentroid = mr.mocap.markerPosition(mr.mocap.markers.rightHand(closestMarkerId(1)),:);
%         end

        % append the plot
        h=findobj(gcf,'tag','closestWall');
        delete(h)
        g=findobj(gcf,'tag','closestWallNeighbors');
        delete(g)
        len = length(mr.am.mazeWalls);
        for n=1:len
            if n==closestWallIdHand
                % redraw the closest wall and its nehigbors,
                % (walls touching) with a new color
                line(mr.am.mazeWalls(n,1:2), mr.am.mazeWalls(n,3:4), 'linewidth', 10, 'color',[.5 .5 .5], 'tag', 'closestWall');
                if ~isempty(mr.am.hasNeighbors{n})
                    for m=1:length(mr.am.hasNeighbors{n})
                        line(mr.am.mazeWalls(mr.am.hasNeighbors{n}(m),1:2), mr.am.mazeWalls(mr.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.5 .5 .5], 'tag', 'closestWallNeighbors');
                    end
                end
            end
        end
        % plot the line from the hand to the nearest wall point
        h=findobj(gcf,'tag','wallDistanceBeam');
        delete(h)
        plot([armCentroid(1) closestWallPointHand(1)],[armCentroid(2) closestWallPointHand(2)], 'r', 'tag','wallDistanceBeam')
        %title(['Distance to the closest wall ' num2str(closestDistance) 'm'])
        
%         h=findobj(gcf,'tag','closestWallPoint');
%         delete(h)
%         plot(closestWallPoint(1), closestWallPoint(2), 'black.', 'tag','closestWallPoint', 'markersize', 60)
        

        
    end
    
    % history of last good markers
    mr.lastHandMarkers = currentHandMarkers;
   
    goodMarkerId = find(mr.mocap.markerPosition(mr.mocap.markers.head,3) > -10); %relies on bad markers having negative z (-100)
    headMarkerId = mr.mocap.markers.head(goodMarkerId);
    if ~isempty(headMarkerId),
        % 11/13/2015 changed to median by DEM
        %headMarkerPosition = mean(mr.mocap.markerPosition(headMarkerId,:),1);
        headMarkerPosition = nanmedian(mr.mocap.markerPosition(headMarkerId,:),1);

        % DEM 1/7/2016
        % check to see if the head is within a circle around an overhead
        % marker
%          headMarkerPosition
%          pdist([mr.overheads(1,:); headMarkerPosition([1 2])], 'euclidean')
        for n=find(mr.tokens.wired) % go through the wired speakers
            
            dist = pdist([mr.tokens.mocapLocs(n,:); headMarkerPosition([1 2])], 'euclidean'); % get the distance
            if(n==1) 
%                 title(['head ' num2str(headMarkerPosition(1)) ' ' num2str(headMarkerPosition(2)) ' token ' num2str(mr.tokens.mocapLocs(n,1)) ' ' num2str(mr.tokens.mocapLocs(n,2)) ' dist' num2str(dist) 'm'])
                title(['time in wall ' num2str(mr.total_time_in_wall) ' time near wall ' num2str(mr.total_time_near_wall)])
%                 mr.total_time_in_wall
%                 mr.total_time_near_wall

            end
            if mr.tokens.active(n) == 0 % it is wired, but not active
                if dist>mr.outTokenTol % check to see if we are far enough to reactivate
                    mr.tokens.active(n) = 1;
                    h=findobj(gcf,'tag','token');
                    delete(h)
                end
            else% it is wired and active, check to see if we are in it
                if dist < mr.inTokenTol
                    plot(mr.tokens.mocapLocs(n,1),mr.tokens.mocapLocs(n,2),'g.','tag','markers','markersize',40)
                    % yes we are, play the sound
                    whatSound = mr.tokens.soundMap(n,2);
                    mr.LSL.MaxMSP.send_overhead(n, whatSound, 'foo'); 
                    mr.tokens.active(n) = 0;
                end
            end   
        end
        lastHeadMarkerPosition = headMarkerPosition;
        noHeadCount = 0;
    else
        %JRI: if it's been < 2 sec since we had a valid head marker, use last
        %known position. Longer than that, default to center of room and
        %print warning
        noHeadCount = noHeadCount + 1;
        if (noHeadCount < 40)
            headMarkerPosition = lastHeadMarkerPosition; %can't find the head! default to 0. Better would be to store the last head position and use that instead
        else
            headMarkerPosition = [0 0 0];
            fprintf(2,'No Head Markers!\n')
        end
    end
    
    % find the nearest wall and the nearest point on that wall to the
    % hand and the head
    [nearestPoints, distances] = mr.am.findNearestPoints((mr.mocap.markerPosition(mr.mocap.markers.head,:)));
    closestDistanceHead = min(distances(:));
    [closestWallIdHead closestMarkerIdHead] = find(distances == closestDistanceHead);
    closestWallPointHead = nearestPoints{closestMarkerIdHead(1)}(closestWallIdHead(1),:);
     
%     %JRI: determine if hand is 'through' the wall--defined as when the 
%     %  closestWallPoint is closer to the head than is the 'armCentroid'
%     
%      
%     % but when we are just using the hands-only mocap montage, there is no
%     % head so it is better to use the center of all mocap sensors (as a
%     % surrogate for the head). This is to prevent isues near protrouded
%     % corners.
%     
% %     validMarkers = find(mr.mocap.markerPosition(:,3) > -100);
% %     headMarkerPosition = mean(mr.mocap.markerPosition(validMarkers,:),1);
%     
%     
    performDirectionSmoothing = false;
    
    % this will have to be adjusted to make way for the new code style
    if performDirectionSmoothing
%         standardDeviationOfEstimatedErrorInDipoleLocationPowerTwo = 0.3 ^ 2;
%         sumWeightedVector = 0;
%         sumWeight = 0;
%         
%         for i=1:size(closestPointForAllWalls,1)
%             wallVector = closestPointForAllWalls(i,:) - headMarkerPosition;
%             wallVector = wallVector / norm(wallVector,'fro');
%             wallWeight(i) = sqrt(1/(2 * pi * standardDeviationOfEstimatedErrorInDipoleLocationPowerTwo)) * exp(-distanceToWalls(i).^2 / (2 * standardDeviationOfEstimatedErrorInDipoleLocationPowerTwo));
%             sumWeightedVector = sumWeightedVector + wallVector * wallWeight(i);
%             sumWeight = sumWeight + wallWeight(i);
%         end;
%         
%         %plot(wallWeight/sum(wallWeight));
%         % plot(closestPointForAllWalls(:,1), closestPointForAllWalls(:,2),'o');
%         finalVector = sumWeightedVector / sumWeight;
%         
%         %        [dummy id] = min(distanceToWalls);
%         %        finalVector = closestPointForAllWalls(id,:) - headMarkerPosition;
%         %
%         projectedAudioPointHand = mr.mocap.roomWallCollection.is_pointed_to_from(headMarkerPosition, finalVector);
%         projectedAudioPointHand(3) = 0;
    else
        % find projection of head to closest maze point and extended to the room
        % perimeter, which has the speakers
        
        
        projectedAudioPointHand = mr.am.findAudioProjection(headMarkerPosition(1:2), closestWallPointHand);
        projectedAudioPointHead = mr.am.findAudioProjection(headMarkerPosition(1:2), closestWallPointHead);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% rewrite, without wallCollection nonesense
        %projectedAudioPoint = mr.mocap.roomWallCollection.is_pointed_to_from(headMarkerPosition, closestWallPoint - headMarkerPosition);
        projectedAudioPointHand(3) = 0;
    end;
    
    % % DEM 10-21-2015
    %figure(11);
    h=findobj(gcf,'tag','audio_point');
    delete(h)
    plot(projectedAudioPointHand(1), projectedAudioPointHand(2),'ro', 'tag','audio_point', 'markersize',30, 'linewidth', 3);
    plot(projectedAudioPointHead(1), projectedAudioPointHead(2),'bo', 'tag','audio_point', 'markersize',30, 'linewidth', 3);
    
    
    angleForInRoomHand = rad2deg(atan2(projectedAudioPointHand(1), projectedAudioPointHand(2))); 
    angleForInRoomHead = rad2deg(atan2(projectedAudioPointHead(1), projectedAudioPointHead(2))); 
    
    
    % DEM 11/13/2015 -- determine if hand is through the wall
    C = armCentroid;
    D = headMarkerPosition;
    % TODO: determine whether the head or the hand crossed the wall?
    if ~wasInWall


        for n=1:length(mr.am.hasNeighbors{closestWallIdHand})
            A = mr.am.mazeWalls(mr.am.hasNeighbors{closestWallIdHand}(n),1:2:3);
            B = mr.am.mazeWalls(mr.am.hasNeighbors{closestWallIdHand}(n),2:2:4);


            isInWall = doesIntersect(A, B, C, D);
            if isInWall
                valueToSendHand = 0;
                inWallId = closestWallIdHand;
               % plot(closestWallPoint(1), closestWallPoint(2), 'red.', 'tag','closestWallPoint', 'markersize', 60)
                break;
            end
        end
    else % hand was in the wall, check to see if it got out
         if whichSide(C, A, B) ~= whichSide(lastArmCentroid, A, B)
             isInWall = false;
         end
    end
    wasInWall = isInWall;
    
    if  closestDistanceHand > mr.proximityDistanceThreshold & ~isInWall
        valueToSendHand = 999;
        nearWallAccumulator = nearWallAccumulator - 2;
        nearWallAccumulator = max(nearWallAccumulator, 0); % do not let it become negative.
        
    else

        valueToSendHand = (closestDistanceHand/mr.proximityDistanceThreshold)^1;
        nearWallAccumulator = nearWallAccumulator + 1;      
        
    end

    % comment this if you want to have periodic car horns when too near a
    % wall
     nearWallAccumulator = 0;
    
    %projectedAudioPoint = projectedAudioPoint * 1000; % 1000 is to convertng from meter to mm
    %angleForInRoom = rad2deg(atan2(-projectedAudioPoint(2), projectedAudioPoint(1))); % x and y are swapped since spat uses angle to y axis

    noiseFreq = 1;
    if closestWallIdHand < 5 % we are near an outer wall
        noiseFreq = 1;
    elseif mr.am.isPointFloating(closestWallPointHand) % check if the hand is near the end of disconnected wall point
        noiseFreq = 2;
        
%         h=findobj(gcf,'tag','closestFloatingPoint');
%         delete(h)
%         plot(closestWallPoint(1), closestWallPoint(2), 'cyan.', 'tag','closestFloatingPoint', 'markersize', 60) 

    else
        noiseFreq = 3;
    end
    mr.LSL.MaxMSP.send_noise_freq(noiseFreq, '');
    
    % routine for keeping track of time passed
    time_is = lsl_local_clock(mr.LSL.lib);
    time_diff =  time_is - mr.time_was;
%     time_diff
    mr.time_was = time_is;
%     valueToSendHand
%     angleForInRoomHand
    if valueToSendHand == 999 % not near enough to the wall
        mr.LSL.MaxMSP.send_hand_proximity(valueToSendHand, angleForInRoomHand, '');
        if mr.was_near_wall == 1
            % TODO?: send event showing time near wall?
            % reset the near wall state and time
            mr.was_near_wall = 0;
            mr.total_time_near_wall = mr.total_time_near_wall+ mr.time_near_wall; % update total time near wall
            mr.time_near_wall = 0;         
        end
    else % near to the wall, possibly in it, do stuff!
        if mr.was_near_wall == 0
            mr.near_wall_cnt = mr.near_wall_cnt+1;
        end
        mr.was_near_wall = 1; % set next state to 'was near wall'
        mr.time_near_wall = mr.time_near_wall + time_diff; % accumulate time near wall
        
        if isInWall % flag as to whether or not we are in the wall
            valueToSendHand = 0;
        end
        
        mr.LSL.MaxMSP.send_hand_proximity(valueToSendHand, angleForInRoomHand, 'wallSound');
         
        if 1-valueToSendHand >=mr.in_wall_prox % wall alarm is sounding
            if mr.was_in_wall == 0 % first frame in wall this time, increase the wall touch counter
                mr.in_wall_cnt = mr.in_wall_cnt+1;
            end
            mr.was_in_wall = 1; % set next state to 'was in wall'
            mr.time_in_wall = mr.time_in_wall + time_diff; % accumulate time in wall              
        elseif mr.was_in_wall == 1 % we are out but we were in on the last tick
            % TODO?: send event showing the time in wall?
            mr.was_in_wall = 0;
            mr.total_time_in_wall = mr.total_time_in_wall + mr.time_in_wall;
            mr.time_in_wall = 0;
        end
           
    end;
    
    % TODO: code for rewarding/punishing subjects for being near/in the
    % wall goes here. I suggest giving them a fixed number of points at the
    % beginning and using this measure to deduct points. 
    
    % for now just send the head distance and create a warning if the head
    % is in the wall
    headwallVal = 999;
    proximityThresholdForHeadInWall = .3;
%      closestDistanceHead
    if closestDistanceHead < proximityThresholdForHeadInWall
        headwallVal = (closestDistanceHead/proximityThresholdForHeadInWall)^1;
    end;
%     headwallVal
%     angleForInRoomHead
    mr.LSL.MaxMSP.send_headwall(headwallVal, angleForInRoomHead,'wallSound');

    % buoy playback control logic
    mr.buoy_time_accum = mr.buoy_time_accum + time_diff;
    if mr.buoy_time_accum > mr.buoy_time_thresh(1) && mr.buoy_trig(1) == 1 %time to play the first buoy
        code = 0;
        mr.LSL.MaxMSP.play_buoy(code, 'foo'); % play it
        mr.buoy_trig(1) = 0; % turn it off
    end
    
    if mr.buoy_time_accum > mr.buoy_time_thresh(2) %time to play the first buoy
        code = 1;
        mr.LSL.MaxMSP.play_buoy(code, 'foo'); % play the other one
        mr.buoy_time_accum = 0; % restart the counter
        mr.buoy_trig(1) = 1; % retrigger the other buoy
        
    end
        
    if nearWallAccumulator > 40 %warn after 2 seconds within wall...
        nearWallAccumulator = 0; % restart the accumulator after 'too long near wall' warning
        mr.LSL.MaxMSP.play_sound(1, 1, 0, angleForInRoomHand, 110, 'tooLongByWallSound');

    end;
    lastArmCentroid = armCentroid;
end;

