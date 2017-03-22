function simpleMaze()
% function for initiating a simple maze session

%set up paths
audiomazeDir = 'c:\Users\mobi\Desktop\audiomaze-2.0';
cd(audiomazeDir)
addpath(fullfile(audiomazeDir,'vr',''));

%% PARAMETER SETTINGS
% these will apply to entire experiment

%set up maze-specific rewards
defaultRewardStructure.maze.A.shape = 'I';
defaultRewardStructure.maze.A.mazeReward = 1;

defaultRewardStructure.maze.B.shape = 'L';
defaultRewardStructure.maze.B.mazeReward = 1;

defaultRewardStructure.maze.C.shape = 'U';
defaultRewardStructure.maze.C.mazeReward = 2;

defaultRewardStructure.maze.D.shape = 'T';
defaultRewardStructure.maze.D.mazeReward = 2;

defaultRewardStructure.maze.E.shape = '+';
defaultRewardStructure.maze.E.mazeReward = 4;

%set up general rewards and penalties
defaultRewardStructure.mazeCompletedBonus = 1; %for exploring entire maze (reaching all goal tokens)
defaultRewardStructure.wallTouchPenalty = 0.1; %for touching 'in' the wall
defaultRewardStructure.wallProximityPenalty = 0.01; %for every touch of the 'warning zone' 

global X;

is_practice = false;

X=[]; %current maze state structure

X.subject_id = input('Enter subject ID: ','s');

which_maze = whichMazePrompt();
if which_maze == 'P'
    which_maze = 'A';
    is_practice = true;
end
X.which_maze = which_maze;
X.rewardStructure.shape = defaultRewardStructure.maze.(X.which_maze).shape;
X.rewardStructure.mazeReward = defaultRewardStructure.maze.(X.which_maze).mazeReward;
X.rewardStructure = copyfields(defaultRewardStructure, X.rewardStructure, {'mazeCompletedBonus', 'wallTouchPenalty', 'wallProximityPenalty'});
X.rewardStructure.rewardReceived = 0.0; 

if ~is_practice,
    X.trial_number = whichTrialPrompt();
    
    fprintf('%s: Initiating maze %s for trial %d\n', X.subject_id, X.which_maze, X.trial_number);
    X = simpleInit(X);
        
    disp('Maze initiated. Press any key to begin.')
    pause
    
    X.LSL.emitInfo(X.which_maze, X.random_seed, X.trial_number);
    
    %debugMocap;
    
    simpleTaskMainLoop; %this accesses global X
    
% special case of practice maze: 
else
    X.trial_number = 0;
    fprintf('Initiating practice maze %s', X.which_maze);
    X=simpleInit(X);
    
    disp('Maze initiated. Press any key to begin.')
    pause
    
    simpleTaskMainLoop; %this accesses global X
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maze = whichMazePrompt()
prompt = 'Enter maze type A-F, or P for practice: ';
choices = 'ABCDEFP';
while true,
    maze = upper(input(prompt,'s'));
    if ~isempty(maze) && any(choices==maze(1)),
        break
    else
        fprintf(2,'Invalid selection. Try again.\n')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trial = whichTrialPrompt()
prompt = 'Enter trial number 1-4: ';
trial = 0;
while (isnan(trial) || trial < 1 || trial > 4),
    str = input(prompt,'s');
    trial = floor(str2double(str));
end
