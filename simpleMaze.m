function simpleMaze()
% function for initiating a simple maze session
% @param which    : upper case character A-F indicating which maze to build
% @param trial_no : which run through the maze (1-3)

%set up maze-specific rewards
rewardStructure.maze.A.shape = 'I';
rewardStructure.maze.A.totalReward = 1;

rewardStructure.maze.B.shape = 'L';
rewardStructure.maze.B.totalReward = 1;

rewardStructure.maze.C.shape = 'U';
rewardStructure.maze.C.totalReward = 2;

rewardStructure.maze.D.shape = 'T';
rewardStructure.maze.D.totalReward = 2;

rewardStructure.maze.E.shape = '+';
rewardStructure.maze.E.totalReward = 4;

%set up general rewards and penalties
rewardStructure.mazeCompletedBonus = 1; %for exploring entire maze (reaching all goal tokens)
rewardStructure.wallTouchPenalty = 0.1; %for touching 'in' the wall
rewardStructure.wallProximityPenalty = 0.01; %for every touch of the 'warning zone' 

global X;
global mazeStopped;

is_practice = false;

X=[]; %current maze state structure

X.subject_id = input('Enter subject ID: ','s');

which_maze = whichMazePrompt();
if which_maze == 'P'
    which_maze = 'A';
    is_practice = true;
end
X.which_maze = which_maze;

if ~is_practice,
    X.trial_number = whichTrialPrompt();
    
    fprintf('%s: Initiating maze %s for trial %d\n', X.subject_id, X.which_maze, X.trial_number);
    X = simpleInit(X);
        
    disp('Maze initiated. Press any key to begin.')
    pause
    
    X.LSL.emitInfo(X.which_maze, X.random_seed, X.trial_number);
    
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
function str = whichMazePrompt()
prompt = 'Enter maze type A-F, or P for practice: ';
choices = 'ABCDEFP';
while true,
    str = upper(input(prompt,'s'));
    str = str(1);
    if any(str==choices),
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
