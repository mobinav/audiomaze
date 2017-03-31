 function X = finalizeScoring(X)
 
 %% finalize scoreing
 X.performance.maxEarning = X.rewardStructure.mazeReward + X.rewardStructure.mazeCompletedBonus * X.performance.foundAllTokens;
 
 X.performance.lost = X.performance.wallTouchScores.hand.numProximityTouches * X.rewardStructure.wallProximityPenalty + ...
     X.performance.wallTouchScores.hand.numWallTouches * X.rewardStructure.wallTouchPenalty;
 
 X.performance.earned = min(0, X.performance.maxEarning - X.performance.lost); %don't let go negative
 
 fprintf(2,'Trial End\n\tmaze value = %g\n\tmaze completed bonus = %g\n\n\t# proximity/wall touches = %d/%d\n\tdeduction = %g\n\nTOTAL = %g\n', ...
     X.rewardStructure.mazeReward, X.rewardStructure.mazeCompletedBonus, X.performance.wallTouchScores.hand.numProximityTouches, ...
     X.performance.wallTouchScores.hand.numWallTouches, X.performance.lost, X.performance.earned);
 
 %save it
 disp('Saving...')
 X.saveFilename = sprintf('%s_maze%s_trial%d.mat',X.subject_id, X.which_maze, X.trial_number);
 %remove irrelevant fields
 keyboard
 X = rmfield(X,'LSL', 'am');
 save(X.saveFilename, 'X')
 
 
      
%      X.rewardStructure
%                    shape: 'U'
%               mazeReward: 2
%       mazeCompletedBonus: 1
%         wallTouchPenalty: 0.1
%     wallProximityPenalty: 0.01
%           rewardReceived: 0

%     blank.numProximityTouches = 0;
%     blank.numWallTouches = 0;
%     blank.numThroughWall = 0;
%     blank.proximityDuration = 0;
%     blank.totalProxmityDuration = 0;
%     blank.wallDuration = 0;
%     blank.totalWallDuration = 0;
%     X.performance.wallTouchScores.hand = blank;
%     X.performance.wallTouchScores.head = blank;
%     X.performance.maxEarning = 0;
%     X.performance.earned = 0;
%     X.performance.lost = 0;
%     X.performance.foundAllTokens = false;
%     X.performance.nFoundTokens = 0;
 
 
 