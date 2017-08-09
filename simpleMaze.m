function simpleMaze(subject_id, which_maze, trial_number)
% function for initiating a simple maze session
close all
stop_maze

%% PARAMETER SETTINGS
% these apply to entire experiment

%save trial results here
saveDirectory = fullfile('C:\Users\mobi\Desktop\AudiomazeTrialData','');

debugMaze = 1; %when true will plot the maze as well as run the debug loop in simpleTaskMainLoop
infiniteWalls = true; %if participant goes through a wall, keep warning regardless of how far they go
inWallFreezeAzimuth = true; %when in wall, fix azimuth, so instructions are clear: back away from the wall sound

% phasespace
% define what phasespace markers we'll use: primetime is suit, but we may
%  use head/hand for debugging from time to time.

phasespaceProfile = 'Audiomaze Suit'; %full suit
%phasespaceProfile = 'Audiomaze Head7 & Hand';
%phasespaceProfile = 'Audiomaze Head4 & Hand';

if strcmp(phasespaceProfile, 'Audiomaze Suit') ~= 1
    warndlg('phasespaceProfile is not full suit!!!');
end

% maze dimensions (# cells)
n_rows = 5;
n_cols = 5;

%maze physical size (meters)
wallThickness = 0.1;
headProximityThresh = .15;
%original maze was larger, we're trying a smaller one to avoid marker
%dropout near edges of room--it's worst in northeast corner, which is not
%part of any maze, but also w/sw wall/corner

if 0,
    w = 6;
    h = 6.5;
    handProximityThresh = .3;
else
    w = 5;
    h = 5;
    handProximityThresh = .2;
end

hasExits = false; %whether to include exits in outer walls (NW / SE corners)

%seed (not used in simple maze)
random_seed = 0;

%do VR plot as well as simple plot?
doVrPlot = false;

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
defaultRewardStructure.maze.F.mazeReward = 3;

%set up general rewards and penalties
defaultRewardStructure.mazeCompletedBonus = 0.5; %for exploring entire maze (reaching all goal tokens)
defaultRewardStructure.wallTouchPenalty = 0.25; %for touching 'in' the wall
defaultRewardStructure.wallProximityPenalty = 0; %for every touch of the 'warning zone' \
defaultRewardStructure.armExtensionPenalty = 0.25; % for extending arm without returning to body

%% general setup
%set up paths
audiomazeDir = 'c:\Users\mobi\Desktop\audiomaze-2.0';
cd(audiomazeDir)
addpath(fullfile(audiomazeDir,'vr',''));

%define master state variable
global X;
X=[];

% which subject/maze/trial? prompt user of nargin ~= 3
if nargin ~= 3
    X.subject_id = input('Enter subject ID: ','s');
    X.which_maze = whichMazePrompt();
    X.trial_number = whichTrialPrompt();
else 
    if ~ischar(subject_id)
        subject_id = sprintf('%.d', subject_id);
    end 
    X.subject_id = subject_id;
    X.which_maze = which_maze;
    X.trial_number = trial_number;
end

is_practice = false;
if X.which_maze == 'P'
    X.which_maze = 'A';
    is_practice = true;
    X.trial_number = 0;
end

%setup other defaults
X.subjectDirectory = ji_fullfile_mkdir(saveDirectory,X.subject_id,'');
X.is_practice = is_practice; 
X.doVrPlot = doVrPlot;
X.debugMaze = debugMaze;
X.infiniteWalls = infiniteWalls;
X.inWallFreezeAzimuth = inWallFreezeAzimuth;
X.phasespaceProfile = phasespaceProfile;

%% initialize maze
fprintf(2,'%s: Initiating %s maze for trial %d%s\n', X.subject_id, X.which_maze, X.trial_number, fastif(is_practice,' (PRACTICE)',''));

% define rewards based on specific maze choice
X.rewardStructure.shape = defaultRewardStructure.maze.(X.which_maze).shape;
X.rewardStructure.mazeReward = defaultRewardStructure.maze.(X.which_maze).mazeReward;
X.rewardStructure = ji_copyfields(defaultRewardStructure, X.rewardStructure, {'mazeCompletedBonus', 'wallTouchPenalty', 'wallProximityPenalty', 'armExtensionPenalty'});
X.rewardStructure.rewardReceived = 0.0;

% maze geometry parameters
X.mazeinfo = ji_packstruct({'n_rows','n_cols','w','h','wallThickness','handProximityThresh','headProximityThresh','random_seed','hasExits'});

% create maze and initialize LSL I/O
X = simpleInit(X);

%% run maze
disp('Maze initiated. Press any key to begin.')
% TODO: enable monitoring of mocap points here, without sound, to verify in
% correct start position
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
