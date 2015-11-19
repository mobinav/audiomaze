function mr = maze_init(varargin)

%   Options... : A list of options to control the maze generation
%   procedure.
%
%                Parameters that control various processing features:
%
%                'RandomMaze' : Wheter or not to do a random maze. (default: true)
%                'RandomSeed' : Variable to control the maze generation. (default: 1)
%                'MazeLines'  : Array containing the endpoints of maze lines. (default: [])
%                   note, this option will turn the RandomMaze flag to
%                   false

    %% check options

    opts = cell2struct(varargin(2:2:end),varargin(1:2:end),2);
    if ~isfield(opts,'RandomMaze')
        opts.RandomMaze = true; end
    if ~isfield(opts,'RandomSeed')
        opts.RandomSeed = 1; end
    if ~isfield(opts,'MazeLines')
        opts.MazeLines = [];
    else
        opts.RandomMaze = false; end
    
    %clear mr;
    %global mr;
    mr = [];
    mr.readFromLSL = true; % ***
    mr.functionHandle = [];
    mr.samplingRate  = 512;%512;
    mr.maxNumberOfFramesInAccumulatedData = 6000;% Inf;
    
    % note: added 11/13/15 DEM
    % mechanism for dealing with emitter drop errors
    % store the last good set of hand emitters and replace 0s 
    % with these values

    %global lastHandMarkers;
    mr.lastHandMarkers = zeros(8,3);

    % mr_init;
    % from the script above:
    maxChannels = 100;
    initialLength = 10000;
    mr.verboseLevel = 1; % 0 is no verbosity, 1 for medium and 2 is for max
    mr.accumulatedData = nan(maxChannels, initialLength);
    mr.numberOfChannelsInAccumulatedData = nan;
    mr.numberOfFramesInAccumulatedData = 0;
    mr.numberOfFramesReceived = 0;
    mr.event = [];
    mr.eventChannelNumber = nan; % when reading from datariver, event channel is not represented as a separate channel, but as the .event field of incoming samples.
    mr.eeg.channelOffset = 0;


    delete(timerfindall);

    %makoto mr_init_writing('/tmp/AudioSuite', 10, 20); 

    mr.numberOfFramesInAccumulatedData = 0;

    % for mocap, specify mocap channel subset
    mr.mocap.firstChannel = 1; % first channel is events or should be ignored
    mr.mocap.lastChannel = nan; % use nan to make it until the last one that exist

    %% vr world stuff -- not implemented yet
    % mr_mocap_init;
    % from the above (don't know if we even need this
    % close and delete any previous mr.mocap.mocapWorld
    % still needs to be implemented
    % if isfield(mr, 'mocap') && isfield(mr.mocap, 'mocapWorld') && ~isempty(mr.mocap.mocapWorld)
    %     close(mr.mocap.mocapWorld);
    %     delete(mr.mocap.mocapWorld);
    % end;
    % cur_dir = pwd;
    % vr_path = strcat(cur_dir,'\vr_files\minimal_with_axis_captions');
    % %mocapWorld = vrworld(['E:\Demo\vr\mocap\minimal_with_axis_captions'], 'new');
    % mocapWorld = vrworld(vr_path, 'new');
    % open(mocapWorld);
    % 
    % mr.mocap.mocapWorld = mocapWorld;

    % mr.mocap.afterInitCallback is a callbck (function or script as string) to be executed after mocap vrml figure
    % is created

    if~isfield(mr.mocap, 'afterInitCallback')
        mr.mocap.afterInitCallback = '';
    end;


    %mr.mocap.afterInitCallback = 'mr_draw_maze; mr.mocap.roomWallCollection = vr_add_sccn_mobi_room(mr.mocap.mocapWorld);';

    % add boundaries of sccn room
    %mr.mocap.roomWallCollection = vr_add_sccn_mobi_room(mr.mocap.mocapWorld); 

    %% maze testing--fix the random seed
    mr.mocap.mazeRandomSeed = opts.RandomSeed;
    %mr.mocap.doVrPlot = true; % commenting out this line confused wall warning system and map configuration too (but refresh rate increased up to 40 Hz); don't delete this line.
    mr.mocap.doSimplePlot = true;

    % for the maze
    % room dimensions
    w = 6.5;
    h = 6.5;
    % new audiomaze type
    % mr.am = audioMaze(h, w, 5, 5, 'S', 0, mr.mocap.mazeRandomSeed); % old
    % initializer
    % now we make the maze lines first -- so we can build our own mazes
    mz_lns = opts.MazeLines;
    if opts.RandomMaze
        [~, mz_lns] = make_maze_polygons(5, 5, 'S', 0, mr.mocap.mazeRandomSeed);
    end
    mr.am = audioMaze(h, w, 5, 5, mz_lns);
    figure(11);
    mr.am.plotMaze();
    hold on;
    %mr.maze.wallCollection = vr_add_maze(mr.mocap.mocapWorld, 1.5, 2, 0.1, 2, mr.mocap.mazeRandomSeed);

    % if mr.mocap.doSimplePlot,
    %     figure(10)
    %     plot_mazem
    %     hold on
    % end

    %% initialize LSL, connect to MaxMSP (via patch lslreceive)
    addpath(genpath('C:\DEVEL\labstreaminglayer\LSL\liblsl-Matlab'));
    if isfield(mr,'LSL'), mr = rmfield(mr,'LSL'); end
    mr.LSL.lib = lsl_loadlib();

    %init outlets to MAX
    disp('Initializing LSL outputs to MAX/MSP')
    mr.LSL.MaxMSP.streamInfo(1) = lsl_streaminfo(mr.LSL.lib,'fileplay','AudioControl',6,0,'cf_string','fileplay_AudioControl');
    mr.LSL.MaxMSP.outlet(1) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(1));
    mr.LSL.MaxMSP.streamInfo(2) = lsl_streaminfo(mr.LSL.lib,'handproximity','AudioControl',3,0,'cf_string','handproximity_AudioControl');
    mr.LSL.MaxMSP.outlet(2) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(2));
    mr.LSL.MaxMSP.streamInfo(3) = lsl_streaminfo(mr.LSL.lib,'noisepitch','AudioControl',2,0,'cf_string','noisepitch_AudioControl');
    mr.LSL.MaxMSP.outlet(3) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(3));
    % functions to play a beacon sound, or wall-proximity sound
    % using previous convention of first 6 values being commands to play beacon
    % sounds from a given azimuth. To control wall proximity sounds, the azimuth, scaled
    % proximity, and wall event code are sent as values 7-9. Consider revising this
    % in future.
    % proximityDistance is scaled from 1(at proximityDistance from wall to 0
    % (touching wall)
    %
    %NB: Max lslaudo receiver only takes 8 arguments and expects first argument
    %to be a .wav. We'll needed to rewrite this
    mr.LSL.MaxMSP.play_sound = @(beaconSoundID, soundOn, loop, azimuth, volume, beaconEventCode) ...
        mr.LSL.MaxMSP.outlet(1).push_sample({num2str(beaconSoundID), num2str(soundOn), num2str(loop), num2str(azimuth),...
        num2str(volume), beaconEventCode});
    mr.LSL.MaxMSP.send_hand_proximity = @(proximityDistance, proximityAzimuth, proximityEventCode) ...
        mr.LSL.MaxMSP.outlet(2).push_sample({num2str(proximityDistance), num2str(proximityAzimuth), proximityEventCode});
    mr.LSL.MaxMSP.send_noise_freq = @(pitch, fooEventCode) ...
        mr.LSL.MaxMSP.outlet(3).push_sample({num2str(pitch), fooEventCode});

    %% init input from phasespace
    streaminfo = {};
    disp('Waiting for Mocap stream...')
    while isempty(streaminfo),
        streaminfo = lsl_resolve_byprop(mr.LSL.lib,'type','Mocap',1); % look for mocap device
        drawnow
    end
    disp('Found Mocap Stream')
    mr.LSL.phasespace.streamInfo = streaminfo{1};
    mr.LSL.phasespace.inlet = lsl_inlet(mr.LSL.phasespace.streamInfo);

    %% set up marker indexes
    %sensor numbers will depend on the phasespace profile used
    % these are for head and gloves
    %

    % %% "head and hands" phasespace configuration
    % if 0,
    %     mr.mocap.markers.phasespaceConfiguration = 'head and hands';
    %     mr.mocap.markers.head = 1:4;
    %     mr.mocap.markers.leftHand = 5:12;
    %     mr.mocap.markers.rightHand = 13:18;
    % end

    %% "Full Body 1 with DG (48)" configuration
    %mr.mocap.markers.phasespaceConfiguration = 'Full Body 1 with DG (48)';
    %mr.mocap.markers.head = [1:3 47];
    %mr.mocap.markers.rightHand = 11:18;
    %mr.mocap.markers.leftHand = 23:30;
    %%

    % "4 gloves, 2 heads (dev)" configureation
    mr.mocap.markers.phasespaceConfiguration = '4 gloves, 2 heads (dev)';
    mr.mocap.markers.head = 1:4;
    mr.mocap.markers.rightHand = 5:12;
    mr.mocap.markers.leftHand = 13:20;


end