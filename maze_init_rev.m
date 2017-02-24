function X = maze_init_rev(maze_lines, n_rows, n_cols, h, w, doVrPlot)
% maze_init_rev  intialize the audio maze and peripherals (mocap, lsl)
%
%   X = maze_init_rev(maze_lines, n_rows, n_cols, h, w, doVrPlot)
%
% state information returned in structure "X"
%
% maze_lines and maze_polygons are generated by a call to
% make_maze_polygons (for a random maze) or make_maze_polygons_nr (for a
% predetermined maze)

if nargin < 6
    doVrPlot = false;
end

X = [];
X.readFromLSL = true; % ***obsolete--used to switch away from datariver
%     X.functionHandle = [];
%     X.samplingRate  = 512;%512;
%     X.maxNumberOfFramesInAccumulatedData = 6000;% Inf;

X.h = h;
X.w = w;

% note: added 11/13/15 DEM
% mechanism for dealing with emitter drop errors
% store the last good set of hand emitters and replace 0s
% with these values

%global lastHandMarkers;
%     X.lastHandMarkers = zeros(8,3);

% mr_init;
% from the script above:
%     maxChannels = 100;
%     initialLength = 10000;
%     X.verboseLevel = 1; % 0 is no verbosity, 1 for medium and 2 is for max
%     X.accumulatedData = nan(maxChannels, initialLength);
%     X.numberOfChannelsInAccumulatedData = nan;
%     X.numberOfFramesInAccumulatedData = 0;
%     X.numberOfFramesReceived = 0;
%     X.event = [];
%     X.eventChannelNumber = nan; % when reading from datariver, event channel is not represented as a separate channel, but as the .event field of incoming samples.
%     X.eeg.channelOffset = 0;

X.doVrPlot = doVrPlot;

%     X.overheads = [0,0]; % test, center of room
%     X.n_overheads = 1;
X.inTokenTol = .45; % 1/3m
X.outTokenTol = 1.5; % you must get this far away until you can replay

% flag for making sure the flourish message is only sent once
X.canFlourish = 0;
%     delete(timerfindall);

% variables for keeping track of wall touch stats in real-time
%     X.was_near_wall = 0;
%     X.time_near_wall = 0;
%     X.total_time_near_wall = 0;
%     X.was_in_wall = 0;
%     X.time_in_wall = 0;
%     X.total_time_in_wall = 0;
%
%     X.in_wall_cnt = 0;
%     X.near_wall_cnt = 0; % counters for wall touches

%     X.head_was_near_wall = 0;
%     X.head_time_near_wall = 0;
%     X.total_head_time_near_wall = 0;
%     X.head_was_in_wall = 0;
%     X.time_head_in_wall = 0;
%     X.total_head_time_in_wall = 0;
%
%     X.head_in_wall_cnt = 0;
%     X.head_near_wall_cnt = 0; % counters for wall touches
%
%     X.time_was = 0;


% 8/26/2016 DEM
X.totalTimeNearWallHand = 0;
X.totalTimeNearWallHead = 0;
X.totalTimeTouchingWallHand = 0;
X.totalTimeTouchingWallHead = 0;
X.totalTimeInWallHand = 0;
X.totalTimeInWallHead = 0;
X.lingeringWallCntHand = 0;
X.touchingWallCntHand = 0;
X.touchingWallCntHead = 0;
X.nearWallCntHand = 0;
X.nearWallCntHead = 0;
X.inWallCntHead = 0;
X.inWallCntHand = 0;
X.inWallCnt = 0;
X.timeTotal = 0;

X.proximityDistanceThreshold = 0.3; %set the distance from wall at which hand proximity sounds will begin
X.headProximityThresh = .15;
X.handProximityThresh = .3;
% determine the 'in wall' proximity threshold according to how max/msp
% understands it (midi units, 0-127)
% the proximity here is 0-1 (once we cross the near wall threshold) so
% we need to map MAX/msp's notion of in the wall to the audiomaze
% engine's notion
MAX_hand_wall_prox_thresh = 90; % got this from the MAX patch
X.hand_in_wall_prox = MAX_hand_wall_prox_thresh/127;

MAX_head_wall_prox_thresh = 90; % got this from the MAX patch
X.head_in_wall_prox = MAX_head_wall_prox_thresh/127;

%X.velocityPlot = figure(12);
% file to hold all the absolute values of velocity for grand total
X.velocityFile = fopen('velocityFile', 'W');

%     % buoy playback control
%     X.buoy_time_accum = 0;
%     X.buoy_time_thresh = [10 20]; % time in the cycle to sound beacon
%     X.buoy_trig = [1 1]; % trigger the sound on or off

%makoto mr_init_writing('/tmp/AudioSuite', 10, 20);

%     X.numberOfFramesInAccumulatedData = 0;

% for mocap, specify mocap channel subset
X.mocap.firstChannel = 1; % first channel is events or should be ignored
X.mocap.lastChannel = nan; % use nan to make it until the last one that exist

X.mocap.doSimplePlot = true;

%     X.onePoleArmCentroid = [];
%     X.lastArmCentroid = [0 0 0];
%     X.lastHeadMarkerPosition = [0 0 0];

%     X.is_in_wall = 0;
%     X.was_in_wall = 0;
%     X.head_crossed = 0;
%     X.hand_crossed = 0;

X.bonus = 1.00;
X.wallTouchDeduction = .10;
X.finished = 0;
X.nearWallAccumThresh = 5;

%% make the maze
X.am = audioMaze(X.h, X.w, n_rows, n_cols, maze_lines);

%figure(11);
X.am.plotMaze();
hold on;


%% vr world stuff
if X.doVrPlot == true;
    if isfield(X, 'mocap') && isfield(X.mocap, 'mocapWorld') && ~isempty(X.mocap.mocapWorld)
        close(X.mocap.mocapWorld);
        delete(X.mocap.mocapWorld);
    end;
    cur_dir = pwd;
    vr_path = strcat(cur_dir,'\vr\minimal_with_axis_captions');
    mocapWorld = vrworld(vr_path, 'new');
    open(mocapWorld);
    
    X.mocap.mocapWorld = mocapWorld;
    X.mocap.roomWallCollection = vr_draw_maze(X.mocap.mocapWorld, X.am);
    
    figureHandle = view(X.mocap.mocapWorld);
    vrdrawnow;
end

%% initialize LSL, connect to MaxMSP (via patch lslreceive)
X = maze_init_LSL_outlets(X); % this function sets up all the LSL objects to send events to the audio engine

%% init input from phasespace
streaminfo = {};
disp('Waiting for Mocap stream...')
while isempty(streaminfo),
    streaminfo = lsl_resolve_byprop(X.LSL.lib,'type','Mocap',1); % look for mocap device
    drawnow
end
disp('Found Mocap Stream')
X.LSL.phasespace.streamInfo = streaminfo{1};
X.LSL.phasespace.inlet = lsl_inlet(X.LSL.phasespace.streamInfo);

%% set up marker indexes
%sensor numbers will depend on the phasespace profile used

%% "Audiomaze Suit 480" configuration (Feb, 2017--optimized 480Hz)
X.mocap.markers.phasespaceConfiguration = 'Audiomaze Suit 480';
X.mocap.markers.head = 1:4; %headCenter al, al, pl, pr
X.mocap.markers.headOrientation = 5:7; %L-Nose-R
X.mocap.markers.rightHand = 16:20;
X.mocap.markers.leftHand = [];

%% "head and hands" phasespace configuration
%     mr.mocap.markers.phasespaceConfiguration = 'head and hands';
%     mr.mocap.markers.head = 1:4;
%     mr.mocap.markers.leftHand = 5:12;
%     mr.mocap.markers.rightHand = 13:18;

%% "Full Body 1 with DG (48)" configuration
%mr.mocap.markers.phasespaceConfiguration = 'Full Body 1 with DG (48)';
%mr.mocap.markers.head = [1:3 47];
%mr.mocap.markers.rightHand = 11:18;
%mr.mocap.markers.leftHand = 23:30;

%% "Audiomaze-2" configuration
%X.mocap.markers.phasespaceConfiguration = 'Audiomaze-2';
%X.mocap.markers.head = 1:4;
%X.mocap.markers.rightHand = 5:12;
%X.mocap.markers.leftHand = 16:23;

%% "audiomaze suit" configuration
%X.mocap.markers.phasespaceConfiguration = 'audiomaze suit';
%X.mocap.markers.head = 1:4;
%X.mocap.markers.rightHand = 21:28;
%X.mocap.markers.leftHand = 33:40;
