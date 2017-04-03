function simpleMaze()
% function for initiating a simple maze session
close all

%% PARAMETER SETTINGS
% these apply to entire experiment

debugMaze = true; %when true will plot the maze as well as run the debug loop in simpleTaskMainLoop

% phasespace
% define what phasespace markers we'll use: primetime is suit, but we may
%  use head/hand for debugging from time to time.
%phasespaceProfile = 'Audiomaze Suit'; %full suit
%phasespaceProfile = 'Audiomaze Head7 & Hand';
phasespaceProfile = 'Audiomaze Head4 & Hand';

% maze dimensions (# cells)
n_rows = 5;
n_cols = 5;

%maze physical size (meters)
 w = 6;
 h = 6.5;
%w = 5;
%h = 5;
hasExits = false; %whether to include exits in outer walls (NW / SE corners)

%seed (not used in simple maze)
random_seed = 0;

%do VR plot as well as simple plot?
doVrPlot = false;

%wall thickness parameters (meters)
wallThickness = 0.1;
handProximityThresh = .3; %set the distance from wall at which hand proximity sounds will begin
headProximityThresh = .15;

%set up maze-specific rewards
defaultRewardStructure.maze.A.shape = 'I';
defaultRewardStructure.maze.A.mazeReward = 1;

defaultRewardStructure.maze.B.shape = 'L';
defaultRewardStructure.maze.B.mazeReward = 1;

defaultRewardStructure.maze.C.shape = 'U';
defaultRewardStructure.maze.C.mazeReward = 2;

defaultRewardStructure.maze.D.shape = 'Z';
defaultRewardStructure.maze.D.mazeReward = 2;

defaultRewardStructure.maze.E.shape = 'T';
defaultRewardStructure.maze.E.mazeReward = 2;

defaultRewardStructure.maze.F.shape = '+';
defaultRewardStructure.maze.F.mazeReward = 4;

%set up general rewards and penalties
defaultRewardStructure.mazeCompletedBonus = 1; %for exploring entire maze (reaching all goal tokens)
defaultRewardStructure.wallTouchPenalty = 0.1; %for touching 'in' the wall
defaultRewardStructure.wallProximityPenalty = 0.01; %for every touch of the 'warning zone' 

%% general setup
%set up paths
audiomazeDir = 'c:\Users\mobi\Desktop\audiomaze-2.0';
audiomazeDir = pwd;
cd(audiomazeDir)
addpath(fullfile(audiomazeDir,'vr',''));

%define master state variable
global X;
X=[];

%% ask user which subject/maze/trial
X.subject_id = input('Enter subject ID: ','s');

is_practice = false;
which_maze = whichMazePrompt();
if which_maze == 'P'
    which_maze = 'A';
    is_practice = true;
end
X.which_maze = which_maze;

if ~is_practice
    X.trial_number = whichTrialPrompt();
else
    X.trial_number = 0;
end

%setup other defaults
X.is_practice = is_practice; 
X.doVrPlot = doVrPlot;
X.debugMaze = debugMaze;
X.phasespaceProfile = phasespaceProfile;

%% initialize maze
fprintf(2,'%s: Initiating %s maze for trial %d%s\n', X.subject_id, X.which_maze, X.trial_number, fastif(is_practice,' (PRACTICE)',''));

% define rewards based on specific maze choice
X.rewardStructure.shape = defaultRewardStructure.maze.(X.which_maze).shape;
X.rewardStructure.mazeReward = defaultRewardStructure.maze.(X.which_maze).mazeReward;
X.rewardStructure = ji_copyfields(defaultRewardStructure, X.rewardStructure, {'mazeCompletedBonus', 'wallTouchPenalty', 'wallProximityPenalty'});
X.rewardStructure.rewardReceived = 0.0;

% maze geometry parameters
X.mazeinfo = ji_packstruct({'n_rows','n_cols','w','h','wallThickness','handProximityThresh','headProximityThresh','random_seed','hasExits'});

% create maze and initialize LSL I/O
X = simpleInit(X);

%% run maze
disp('Maze initiated. Press any key to begin.')
pause
X.LSL.emitInfo(X.which_maze, X.mazeinfo.random_seed, X.trial_number);

%debugMocap; %use this for low-level debugging of raw phasespace LSL output

simpleTaskMainLoop; %this accesses _global_ X, may eventually rewrite to pass X explicitly

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maze = whichMazePrompt()
prompt = 'Enter maze type A-F, or P for practice: ';
choices = 'ABCDEFP';
while true
    maze = upper(input(prompt,'s'));
    if ~isempty(maze) && any(choices==maze(1))
        break
    else
        fprintf(2,'Invalid selection. Try again.\n')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trial = whichTrialPrompt()
prompt = 'Enter trial number 1-4: ';
trial = 0;
while (isnan(trial) || trial < 1 || trial > 4)
    str = input(prompt,'s');
    trial = floor(str2double(str));
end
