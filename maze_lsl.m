    %function X = mr_maze_lsl(X)
    function mr_maze_lsl
    % main maze code--takes markers and calculates hand proximity to maze
    % walls, sends messages to Max when near wall to play sound
    %
    % mr_maze version converted to use LSL
    % 12/13, MM&JRI

    %holdover from datariver days, we'll adapt it for our own purposes if
    %necessary
    %global mr;
    global X;
    persistent nearWallAccumulator 
    persistent A B C D
    persistent lastWallIdHead lastWallIdHand
    SR=50;
    fco = 10;
    omega = fco/SR;
    p = 1-omega;
    norm = 1-p;
    noHeadCount=0;
    closestWallPointHand = [0 0];
    closestDistanceHand = 1;
    closestWallIdHand = 1;
    closestWallPointHead = [0 0];
    closestDistanceHead = 1;
    closestWallIdHead = 1;

    armCentroid = [0 0 0];

    isWallPointFloating = false;
    
    send_cross_marker = 0;
    send_uncross_marker = 0;
    send_near_wall_marker = 0;
    send_touch_wall_marker = 0;
    
    send_buoy_marker = 0;
    send_wall_event = 0;
    send_token_event = 0;

    %% 
    time_is = lsl_local_clock(X.LSL.lib);
    % routine for keeping track of time passed
    time_diff =  time_is - X.time_was;
    X.time_was = time_is;
    if X.numberOfFramesInAccumulatedData == 1 % do any initializing here
        lastWallIdHead = 1;
        lastWallIdHand = 1;
    end
    if X.numberOfFramesInAccumulatedData > 5 %only run if we have at least four frames of phsasespace 



        % 11/13/2015 DEM
        % using lastHandMarkers to fill in 'bad' markers
        % currentHandMarkers = mr.mocap.markerPosition(mr.mocap.markers.rightHand,:); % all hand
        % just fingertips
         currentHandMarkers = X.mocap.markerPosition(X.mocap.markers.rightHand(1:4),:);  
         currentHandMarkers = [currentHandMarkers;X.mocap.markerPosition(X.mocap.markers.rightHand(6),:)];

        for n=1:length(currentHandMarkers)
            if currentHandMarkers(n, 1:2) == [0 0]
                currentHandMarkers(n,:) = X.lastHandMarkers(n,:);
            end
        end



        %%%%%%%%%%%%%%%%%%%%%%%
        %%% Added by Makoto %%%
        %%%%%%%%%%%%%%%%%%%%%%%
        % plot beam to the closest WallPoint
        goodHandMarkerId = find(X.mocap.markerPosition(X.mocap.markers.rightHand,3)> -10);
        if ~isempty(goodHandMarkerId),

            % find hand location
            armCentroid = median(currentHandMarkers);
            % y(n)=(x(n) + p*ym1)*norm; simple normalized one pole, omega =
            % 10
            %X.smoothArmCentroid = norm*(armCentroid + p*X.lastArmCentroid);

            % find the nearest wall and the nearest point on that wall to the
            % hand
            [nearestPoints, distances] = X.am.findNearestPoints(armCentroid);%(mr.mocap.markerPosition(mr.mocap.markers.rightHand,:));
            closestDistanceHand = min(distances(:));
            [closestWallIdHand closestMarkerIdHand] = find(distances == closestDistanceHand);
            closestWallPointHand = nearestPoints{closestMarkerIdHand(1)}(closestWallIdHand(1),:);

            % nearest wall and point to the head
            [nearestPoints, distances] = X.am.findNearestPoints((X.mocap.markerPosition(X.mocap.markers.head,:)));
            closestDistanceHead = min(distances(:));
            [closestWallIdHead closestMarkerIdHead] = find(distances == closestDistanceHead);
            closestWallPointHead = nearestPoints{closestMarkerIdHead(1)}(closestWallIdHead(1),:);

            if length(closestWallIdHand)>1 % at some corners, it will find two points here and go haywire
                closestWallIdHand = closestWallIdHand(1); % arbitrarily choose the first one
                closestMarkerIdHand = closestMarkerIdHand(1); % same thing here
            end

            % append the plot
            h=findobj(gcf,'tag','closestWall');
            delete(h)
            g=findobj(gcf,'tag','closestWallNeighbors');
            delete(g)
            len = length(X.am.mazeWalls);
            for n=1:len
                if n==closestWallIdHand
                    
                    % redraw the closest wall and its nehigbors,
                    % (walls touching) with a new color
                    %line(X.am.mazeWalls(n,1:2), X.am.mazeWalls(n,3:4), 'linewidth', 10, 'color', 'red', 'tag', 'closestWall');
                    if ~isempty(X.am.hasNeighbors{n})
                        for m=1:length(X.am.hasNeighbors{n})
                            line(X.am.mazeWalls(X.am.hasNeighbors{n}(m),1:2), X.am.mazeWalls(X.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.9 .5 .5], 'tag', 'closestWallNeighbors');
                        end
                    end
                end
                
                if n==closestWallIdHead
                    
                    % redraw the closest wall and its nehigbors,
                    % (walls touching) with a new color
                    %line(X.am.mazeWalls(n,1:2), X.am.mazeWalls(n,3:4), 'linewidth', 10, 'color', 'blue', 'tag', 'closestWall');
                    if ~isempty(X.am.hasNeighbors{n})
                        for m=1:length(X.am.hasNeighbors{n})
                            line(X.am.mazeWalls(X.am.hasNeighbors{n}(m),1:2), X.am.mazeWalls(X.am.hasNeighbors{n}(m),3:4), 'linewidth', 10, 'color',[.5 .5 .9], 'tag', 'closestWallNeighbors');
                        end
                    end
                end
            end
            
            % plot the line from the hand to the nearest wall point
            h=findobj(gcf,'tag','wallDistanceBeam');
            delete(h)
            plot([armCentroid(1) closestWallPointHand(1)],[armCentroid(2) closestWallPointHand(2)], 'r', 'tag','wallDistanceBeam')

        end

        % history of last good markers
        X.lastHandMarkers = currentHandMarkers;

        goodMarkerId = find(X.mocap.markerPosition(X.mocap.markers.head,3) > -10); %relies on bad markers having negative z (-100)
        headMarkerId = X.mocap.markers.head(goodMarkerId);
        if ~isempty(headMarkerId),
            
            % 11/13/2015 changed to median by DEM
            % headMarkerPosition = mean(mr.mocap.markerPosition(headMarkerId,:),1);
            % consider changing this to John's head position tracker?
            headMarkerPosition = nanmedian(X.mocap.markerPosition(headMarkerId,:),1);

            % DEM 1/7/2016
            % check to see if the head is within a circle around an overhead
            % marker
            
%            headMarkerPosition
%            pdist([mr.overheads(1,:); headMarkerPosition([1 2])], 'euclidean')

            for n=find(X.tokens.wired) % go through the wired speakers

                dist = pdist([X.tokens.mocapLocs(n,:); headMarkerPosition([1 2])], 'euclidean'); % get the distance
                
%                 if(n==1) 
%                      title(['head ' num2str(headMarkerPosition(1)) ' ' num2str(headMarkerPosition(2)) ' token ' num2str(mr.tokens.mocapLocs(n,1)) ' ' num2str(mr.tokens.mocapLocs(n,2)) ' dist' num2str(dist) 'm'])
%                      title(['time in wall ' num2str(X.total_time_in_wall) ' time near wall ' num2str(X.total_time_near_wall)])
%                      title(['is in wall ' num2str(X.is_in_wall)])
% 
%                 end

                if X.tokens.active(n) == 0 % it is wired, but not active
                    if dist>X.outTokenTol % check to see if we are far enough to reactivate
                        X.tokens.active(n) = 1;
                        h=findobj(gcf,'tag','token');
                        delete(h)
                    end
                else % it is wired and active, check to see if we are in it
                    if dist < X.inTokenTol

                        if n==X.tokens.end1_idx
                            plot(X.tokens.mocapLocs(n,1),X.tokens.mocapLocs(n,2),'b.','tag','markers','markersize',40)
                            if X.tokens.endpoints_hit == 0 % made it to the end
                                
                                % play flourish 1.
                                 X.LSL.MaxMSP.play_flourish(0, 'foo')
                                % send event that we made it
                                X.tokens.endpoints_hit = 1;
                            end

                        elseif n == X.tokens.end2_idx 
                            plot(X.tokens.mocapLocs(n,1),X.tokens.mocapLocs(n,2),'b.','tag','markers','markersize',40)
                            if X.tokens.endpoints_hit == 1 % made it home
                                % play flourish 2.
                                 X.LSL.MaxMSP.play_flourish(1, 'foo')
                                % send event that we made it
                                X.tokens.endpoints_hit = 2;
                            end
                        else
                            plot(X.tokens.mocapLocs(n,1),X.tokens.mocapLocs(n,2),'g.','tag','markers','markersize',40)
                            whatSound = X.tokens.soundMap(n,2);
                            
                            X.LSL.MaxMSP.send_overhead(n, whatSound, 'foo'); 
                            X.tokens.active(n) = 0;
                        end
                    end
                end
                
            end
            


 
            noHeadCount = 0;
        else
            %JRI: if it's been < 2 sec since we had a valid head marker, use last
            %known position. Longer than that, default to center of room and
            %print warning
            noHeadCount = noHeadCount + 1;
            if (noHeadCount < 40)
                headMarkerPosition = X.lastHeadMarkerPosition; %can't find the head! default to 0. Better would be to store the last head position and use that instead
            else
                headMarkerPosition = [0 0 0];
                fprintf(2,'No Head Markers!\n')
            end
        end


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


            projectedAudioPointHand = X.am.findAudioProjection(headMarkerPosition(1:2), closestWallPointHand);
            projectedAudioPointHead = X.am.findAudioProjection(headMarkerPosition(1:2), closestWallPointHead);
            projectedAudioPointHand(3) = 0;
            projectedAudioPointHead(3) = 0;
            
        end;

        % % DEM 10-21-2015
        %figure(11);
        h=findobj(gcf,'tag','audio_point');
        delete(h)
        plot(projectedAudioPointHand(1), projectedAudioPointHand(2),'ro', 'tag','audio_point', 'markersize',30, 'linewidth', 3);
        plot(projectedAudioPointHead(1), projectedAudioPointHead(2),'bo', 'tag','audio_point', 'markersize',30, 'linewidth', 3);


        angleForInRoomHand = rad2deg(atan2(projectedAudioPointHand(1), projectedAudioPointHand(2))); 
        angleForInRoomHead = rad2deg(atan2(projectedAudioPointHead(1), projectedAudioPointHead(2))); 


        % DEM 11/13/2015 -- determine if hand or head is through the wall
        C = armCentroid;
        D = headMarkerPosition;
       
%         if ~X.was_in_wall
%             
%             % check for hand crossing wall
%             for n=1:length(X.am.hasNeighbors{closestWallIdHand})
%                 A = X.am.mazeWalls(X.am.hasNeighbors{closestWallIdHand}(n),1:2:3);
%                 B = X.am.mazeWalls(X.am.hasNeighbors{closestWallIdHand}(n),2:2:4);
%                 
%                 
%                 X.is_in_wall = doesIntersect(A, B, C, D);
%                 if X.is_in_wall
%                     valueToSendHand = 0;
%                     lastWallIdHand = closestWallIdHand;
%                     lastWallA = A;
%                     lastWallB = B;
%                     %plot(closestWallPoint(1), closestWallPoint(2), 'red.', 'tag','closestWallPoint', 'markersize', 60)
%                     break;
%                 end
%             end
%             
%             % check for head crossing wall, but only if the head is visible
%             if closestDistanceHead < 100; % this is a huge number if not head markers are visible
%                 for n=1:length(X.am.hasNeighbors{closestWallIdHead})
%                     A = X.am.mazeWalls(X.am.hasNeighbors{closestWallIdHead}(n),1:2:3);
%                     B = X.am.mazeWalls(X.am.hasNeighbors{closestWallIdHead}(n),2:2:4);
% 
% 
%                     X.is_in_wall = doesIntersect(A, B, C, D);
%                     if X.is_in_wall
%                         valueToSendHand = 0;
%                         lastWallIdHead = closestWallIdHead;
%                         lastWallA = A;
%                         lastWallB = B;
%                         %plot(closestWallPoint(1), closestWallPoint(2), 'red.', 'tag','closestWallPoint', 'markersize', 60)
%                         break;
%                     end
%                 end
%             end
%         else % hand was in the wall, check to see if it got out
%             if X.hand_crossed == 1 % the hand went accross first, so it needs to go back
%                 for n=1:length(X.am.hasNeighbors{lastWallIdHand})
%                     A = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHand}(n),1:2:3);
%                     B = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHand}(n),2:2:4);
% 
%                     if whichSide(C, A, B) ~= whichSide(X.lastArmCentroid, A, B)
%                         X.is_in_wall = false;
%                         X.hand_crossed = 0;
%                         %%%%%% out of wall hand HED marker goes here %%%%%%
%                     end
%                 end
%             end
%             if X.head_crossed == 1
%                 for n=1:length(X.am.hasNeighbors{lastWallIdHead})
%                     A = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHead}(n),1:2:3);
%                     B = X.am.mazeWalls(X.am.hasNeighbors{lastWallIdHead}(n),2:2:4);
%                     if whichSide(D, A, B) ~= whichSide(X.lastHeadMarkerPosition, A, B)
%                         X.is_in_wall = false;
%                         X.head_crossed = 0;
%                         %%%%%% out of wall head HED marker goes here %%%%%%
%                     end
%                 end
%                 
%             end
%         end
%         X.was_in_wall= X.is_in_wall;

        if  closestDistanceHand > X.proximityDistanceThreshold & ~X.is_in_wall
            valueToSendHand = 999;
            nearWallAccumulator = nearWallAccumulator - 2;
            nearWallAccumulator = max(nearWallAccumulator, 0); % do not let it become negative.
            X.is_near_wall = 0;

        else
            valueToSendHand = (closestDistanceHand/X.proximityDistanceThreshold)^1;
            nearWallAccumulator = nearWallAccumulator + 1;    
            
            %%%%%% near or alarming hand HED marker goes here %%%%%%

        end

        % comment this if you want to have periodic car horns when too near a
        % wall
         nearWallAccumulator = 0;

        % projectedAudioPoint = projectedAudioPoint * 1000; % 1000 is to convertng from meter to mm
        % angleForInRoom = rad2deg(atan2(-projectedAudioPoint(2), projectedAudioPoint(1))); % x and y are swapped since spat uses angle to y axis

        noiseFreq = 1;
        if closestWallIdHand < 5 % we are near an outer wall
            noiseFreq = 1;
        elseif X.am.isPointFloating(closestWallPointHand) % check if the hand is near the end of disconnected wall point
            noiseFreq = 2;
        else
            noiseFreq = 3;
        end
        X.LSL.MaxMSP.send_noise_freq(noiseFreq, '');



        if valueToSendHand == 999 % not near enough to the wall
            X.LSL.MaxMSP.send_hand_proximity(valueToSendHand, angleForInRoomHand, '');
            if X.was_near_wall == 1
                % reset the near wall state and time
                X.was_near_wall = 0;
                X.total_time_near_wall = X.total_time_near_wall+ X.time_near_wall; % update total time near wall
                X.time_near_wall = 0;         
            end
        else % near to the wall, possibly in it, do stuff!
            if X.was_near_wall == 0
                X.near_wall_cnt = X.near_wall_cnt+1;
            end
            X.was_near_wall = 1; % set next state to 'was near wall'
            X.time_near_wall = X.time_near_wall + time_diff; % accumulate time near wall

            if X.is_in_wall % flag as to whether or not we are in the wall
                valueToSendHand = 0;
            end

            X.LSL.MaxMSP.send_hand_proximity(valueToSendHand, angleForInRoomHand, 'wallSound');

            if 1-valueToSendHand >=X.hand_in_wall_prox % wall alarm is sounding
                if X.was_in_wall == 0 % first frame in wall this time, increase the wall touch counter
                    X.in_wall_cnt = X.in_wall_cnt+1;
                    X.hand_crossed = 1; % remember that the hand crossed the wall
                end

                X.time_in_wall = X.time_in_wall + time_diff; % accumulate time in wall              
            elseif X.was_in_wall == 1 % we are out but we were in on the last tick
                X.was_in_wall = 0;
                X.total_time_in_wall = X.total_time_in_wall + X.time_in_wall;
                X.time_in_wall = 0;
            end

        end;

        % TODO: code for rewarding/punishing subjects for being near/in the
        % wall goes here. I suggest giving them a fixed number of points at the
        % beginning and using this measure to deduct points. 

        % for now just send the head distance and create a warning if the head
        % is in the wall
        headwallVal = 999;
        proximityThresholdForHeadInWall = .15;
        if closestDistanceHead < proximityThresholdForHeadInWall
            headwallVal = (closestDistanceHead/proximityThresholdForHeadInWall)^1;
        end;
        X.LSL.MaxMSP.send_headwall(headwallVal, angleForInRoomHead,'wallSound');
        if 1-headwallVal >=X.head_in_wall_prox % wall alarm is sounding
            if X.head_was_in_wall == 0 % first frame in wall this time, increase the wall touch counter
                X.head_in_wall_cnt = X.head_in_wall_cnt+1;
                X.head_crossed = 1; % remember that the hand crossed the wall
            end
            X.head_was_in_wall = 1; % set next state to 'was in wall'
            X.head_time_in_wall = X.head_time_in_wall + time_diff; % accumulate time in wall
        elseif X.head_was_in_wall == 1 % we are out but we were in on the last tick
            % TODO?: send event showing the time in wall?
            X.head_was_in_wall = 0;
            X.total_head_time_in_wall = X.total_head_time_in_wall + X.head_time_in_wall;
            X.time_head_in_wall = 0;
        end


        % buoy playback control logic
        X.buoy_time_accum = X.buoy_time_accum + time_diff;
        if X.buoy_time_accum > X.buoy_time_thresh(1) && X.buoy_trig(1) == 1 %time to play the first buoy
            code = 0;
            X.LSL.MaxMSP.play_buoy(code, 'foo'); % play it
            X.buoy_trig(1) = 0; % turn it off
        end

%         if X.buoy_time_accum > X.buoy_time_thresh(2) %time to play the first buoy
%             code = 1;
%             X.LSL.MaxMSP.play_buoy(code, 'foo'); % play the other one
%             X.buoy_time_accum = 0; % restart the counter
%             X.buoy_trig(1) = 1; % retrigger the other buoy
% 
%         end

        if nearWallAccumulator > 40 %warn after 2 seconds within wall...
            nearWallAccumulator = 0; % restart the accumulator after 'too long near wall' warning
            X.LSL.MaxMSP.play_sound(1, 1, 0, angleForInRoomHand, 110, 'tooLongByWallSound');

        end;
        X.lastArmCentroid = armCentroid;
        X.lastHeadMarkerPosition = headMarkerPosition;
    end;


end
