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
closestWallPoint = [0 0];
closestDistance = 1;
closestWallId = 1;
inWallId = 1;
isInWall = false;
wasInWall = false;
armCentroid = [0 0];
lastArmCentroid = [0 0];
isWallPointFloating = false;

%% start the beacon--from the door area of the lab (maze exit)
if mr.numberOfFramesInAccumulatedData > 5 %only run if we have at least four frames of phsasespace data?
    

    
    
    
    
    
    % target sound
    if  isempty(homingSoundTurnedOn),
        % evet-code-to-datariver control1 (angle) control2(azimuth)
        % event_to_be returned_in_audioSend volume azimuth repeat on/off
        % filename
        %mr.LSL.MaxMSP.play_sound(3, 1, 1, 140, 95, 'beacon3'); %sound number 3, loop, from azimuth 135 degrees
        %mr.LSL.MaxMSP.play_sound(0, 0, 0, 0, 0, 0); %? turn all off?
        %disp('Will be replaced with LSL') % mr_write_buffer('/tmp/AudioSuite', 0, [0  0 0 3 110 135 1 1 3]');
        %disp('Will be replaced with LSL') % mr_write_buffer('/tmp/AudioSuite', 0, [0  0 0 0 0 0 0 0 0]');
        
        homingSoundTurnedOn = true;
        tic;
    else
        %mr.LSL.MaxMSP.play_sound(3, 0, 0, 135, 110, 'beacon3'); %sound number 3, loop, from azimuth 135 degrees
    end;
    % homing sound
%     if toc > 10
%         mr_write_buffer('/tmp/AudioSuite',  [0 0 0 4 110 0 0 1 3]');
%         mr_write_buffer('/tmp/AudioSuite',  [0 0 0 0 0 0 0 0 0]');
%         tic
%     end;
    
    if isempty(nearWallAccumulator)
        nearWallAccumulator = 0;
    end;
        
     % MM/JRI use first 4 sensors, which is defined as head in the montage
    %  Head marker is so important for localization, we're using four
    %  markers for redundancy. Find average of good ones
    
    
    % Revision by David Medine, 10/2015
    % take the new notion of a maze, and determine the nearest point on the
    % nearest wall -- then return that point
    



    % 11/13/2015 DEM
    % using lastHandMarkers to fill in 'bad' markers
    currentHandMarkers = mr.mocap.markerPosition(mr.mocap.markers.rightHand,:);
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
        % nearest point on every wall
        armCentroid = median(currentHandMarkers);
        
        [nearestPoints, distances] = mr.am.findNearestPoints(armCentroid);%(mr.mocap.markerPosition(mr.mocap.markers.rightHand,:));
        closestDistance = min(distances(:));
        [closestWallId closestMarkerId] = find(distances == closestDistance);
        closestWallPoint = nearestPoints{closestMarkerId(1)}(closestWallId(1),:);
        
        if length(closestWallId)>1 % at some corners, it will find two points here and go haywire
            closestWallId = closestWallId(1); % arbitrarily choose the first one
            closestMarkerId = closestMarkerId(1); % same thing here
        end
%         if 0,
%             armCentroid = mean(mr.mocap.markerPosition(mr.mocap.markers.rightHand(goodHandMarkerId),:));
%         else
%             armCentroid = mr.mocap.markerPosition(mr.mocap.markers.rightHand(closestMarkerId(1)),:);
%         end
        h=findobj(gcf,'tag','closestWall');
        delete(h)
        g=findobj(gcf,'tag','closestWallNeighbors');
        delete(g)
        len = length(mr.am.mazeWalls);
        for n=1:len
            if n==closestWallId
                line(mr.am.mazeWalls(n,1:2), mr.am.mazeWalls(n,3:4), 'linewidth', 10, 'color',[.5 .5 .5], 'tag', 'closestWall');
                if ~isempty(mr.am.hasNeighbors{n})
                    for m=1:length(mr.am.hasNeighbors{n})
                        line(mr.am.mazeWalls(mr.am.hasNeighbors{n}(m),1:2), mr.am.mazeWalls(mr.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.5 .5 .5], 'tag', 'closestWallNeighbors');
                    end
                end
            end
        end
        h=findobj(gcf,'tag','wallDistanceBeam');
        delete(h)
        plot([armCentroid(1) closestWallPoint(1)],[armCentroid(2) closestWallPoint(2)], 'r', 'tag','wallDistanceBeam')
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
%     
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
        standardDeviationOfEstimatedErrorInDipoleLocationPowerTwo = 0.3 ^ 2;
        sumWeightedVector = 0;
        sumWeight = 0;
        
        for i=1:size(closestPointForAllWalls,1)
            wallVector = closestPointForAllWalls(i,:) - headMarkerPosition;
            wallVector = wallVector / norm(wallVector,'fro');
            wallWeight(i) = sqrt(1/(2 * pi * standardDeviationOfEstimatedErrorInDipoleLocationPowerTwo)) * exp(-distanceToWalls(i).^2 / (2 * standardDeviationOfEstimatedErrorInDipoleLocationPowerTwo));
            sumWeightedVector = sumWeightedVector + wallVector * wallWeight(i);
            sumWeight = sumWeight + wallWeight(i);
        end;
        
        %plot(wallWeight/sum(wallWeight));
        % plot(closestPointForAllWalls(:,1), closestPointForAllWalls(:,2),'o');
        finalVector = sumWeightedVector / sumWeight;
        
        %        [dummy id] = min(distanceToWalls);
        %        finalVector = closestPointForAllWalls(id,:) - headMarkerPosition;
        %
        projectedAudioPoint = mr.mocap.roomWallCollection.is_pointed_to_from(headMarkerPosition, finalVector);
        projectedAudioPoint(3) = 0;
    else
        % find projection of head to closest maze point and extended to the room
        % perimeter, which has the speakers
        
        
        projectedAudioPoint = mr.am.findAudioProjection(headMarkerPosition(1:2), closestWallPoint);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% rewrite, without wallCollection nonesense
        %projectedAudioPoint = mr.mocap.roomWallCollection.is_pointed_to_from(headMarkerPosition, closestWallPoint - headMarkerPosition);
        projectedAudioPoint(3) = 0;
    end;
    
    % % DEM 10-21-2015
    figure(11);
    h=findobj(gcf,'tag','audio_point');
    delete(h)
    plot(projectedAudioPoint(1), projectedAudioPoint(2),'go', 'tag','audio_point', 'markersize',30);
    angleForInRoom = rad2deg(atan2(projectedAudioPoint(1), projectedAudioPoint(2))); 
    
    
    % DEM 11/13/2015 -- determine if hand is through the wall
    C = armCentroid;
    D = headMarkerPosition;
    if ~wasInWall


        for n=1:length(mr.am.hasNeighbors{closestWallId})
            A = mr.am.mazeWalls(mr.am.hasNeighbors{closestWallId}(n),1:2:3);
            B = mr.am.mazeWalls(mr.am.hasNeighbors{closestWallId}(n),2:2:4);


            isInWall = doesIntersect(A, B, C, D);
            if isInWall
                valueToSend = 0;
                inWallId = closestWallId;
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
    
    proximityDistanceThreshold = 0.3; %set the distance from wall at which hand proximity sounds will begin
    if  closestDistance > proximityDistanceThreshold & ~isInWall
        valueToSend = 999;
        nearWallAccumulator = nearWallAccumulator - 2;
        nearWallAccumulator = max(nearWallAccumulator, 0); % do not let it become negative.
        
    else

        valueToSend = (closestDistance/proximityDistanceThreshold)^1;
        nearWallAccumulator = nearWallAccumulator + 1;      
        
    end

    % comment this if you want to have periodic car horns when too near a
    % wall
     nearWallAccumulator = 0;
    
    %projectedAudioPoint = projectedAudioPoint * 1000; % 1000 is to convertng from meter to mm
    %angleForInRoom = rad2deg(atan2(-projectedAudioPoint(2), projectedAudioPoint(1))); % x and y are swapped since spat uses angle to y axis

    noiseFreq = 1;
    if closestWallId < 5 % we are near an outer wall
        noiseFreq = 1;
    elseif mr.am.isPointFloating(closestWallPoint)
        noiseFreq = 2;
        
%         h=findobj(gcf,'tag','closestFloatingPoint');
%         delete(h)
%         plot(closestWallPoint(1), closestWallPoint(2), 'cyan.', 'tag','closestFloatingPoint', 'markersize', 60) 

    else
        noiseFreq = 3;
    end
    mr.LSL.MaxMSP.send_noise_freq(noiseFreq, '');
    
    if valueToSend == 999 % not near enough to the wall
        mr.LSL.MaxMSP.send_hand_proximity(valueToSend, angleForInRoom, ''); %do we want to send this repeatedly??
        %mr_write_buffer('/tmp/AudioSuite', 0, [0  angleForInRoom valueToSend 0 0 0 0 0 0 0]');
        
    else
        if isInWall % flag as to whether or not we are in the wall
            valueToSend = 0;
        end
         mr.LSL.MaxMSP.send_hand_proximity(valueToSend, angleForInRoom, 'wallSound');
         

    end;
    
    if nearWallAccumulator > 40 %warn after 2 seconds within wall...
        nearWallAccumulator = 0; % restart the accumulator after 'too long near wall' warning
        mr.LSL.MaxMSP.play_sound(1, 1, 0, angleForInRoom, 110, 'tooLongByWallSound');

    end;
    lastArmCentroid = armCentroid;
end;

