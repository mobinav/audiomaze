 function X = finalizeScoring(X)
% finalizeScoring  compute scores, display, and save entire trial state
 
 %score rates are defined in simpleMaze and stored in X.rewardStructure
 % files are saved in X.subjectDirectory in timestamped file labeled by
 % maze and trial
 
 % SCORING
 %maximum possible includes a maze-dependent max (depends on number of
 %endpoints to find), and a completion bonus if found all endpoints.
 X.performance.maxEarning = X.rewardStructure.mazeReward + X.rewardStructure.mazeCompletedBonus * X.performance.foundAllTokens;
 
 %penalized for number of wall touches and number of wall proximity touches
 X.performance.lost = X.performance.wallTouchScores.hand.numProximityTouches * X.rewardStructure.wallProximityPenalty + ...
     X.performance.wallTouchScores.hand.numWallTouches * X.rewardStructure.wallTouchPenalty;
 
 % earning for this trial
 X.performance.earned = max(0, X.performance.maxEarning - X.performance.lost); %don't let go negative
 
 fprintf(2,'Maze %s, Trial %d End\n\tmaze value = %g\n\tmaze completed bonus = %g\n\n\t# proximity/wall touches = %d/%d\n\tdeduction = %g\n\nTOTAL = %g\n', ...
     X.which_maze, X.trial_number, X.rewardStructure.mazeReward, X.rewardStructure.mazeCompletedBonus, X.performance.wallTouchScores.hand.numProximityTouches, ...
     X.performance.wallTouchScores.hand.numWallTouches, X.performance.lost, X.performance.earned);
 
 % SAVE
 disp('Saving...')
 X.saveFilename = fullfile(X.subjectDirectory, sprintf('%s_maze%s_trial%d_%s.mat',X.subject_id, X.which_maze, X.trial_number, datestr(now,'yyyy-mm-dd_HH-MM-SS')));
 
 %remove irrelevant fields
 trialData = rmfield(X,{'LSL', 'am','mocap'});
 save(X.saveFilename, 'trialData')

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
 
 
 