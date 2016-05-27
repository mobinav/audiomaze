function X = maze_init_audio_engine(X)  

    addpath(genpath('C:\DEVEL\labstreaminglayer\LSL\liblsl-Matlab'));
    if isfield(X,'LSL'), X = rmfield(X,'LSL'); end
    X.LSL.lib = lsl_loadlib();

    % while we are at it, initiallize the current clock time
    X.time_was = lsl_local_clock(X.LSL.lib);
    %init outlets to MAX
    disp('Initializing LSL outputs to MAX/MSP')

    X.LSL.MaxMSP.streamInfo(1) = lsl_streaminfo(X.LSL.lib,'fileplay','AudioControl',6,0,'cf_string','fileplay_AudioControl');
    X.LSL.MaxMSP.outlet(1) = lsl_outlet(X.LSL.MaxMSP.streamInfo(1));

    X.LSL.MaxMSP.streamInfo(2) = lsl_streaminfo(X.LSL.lib,'handproximity','AudioControl',3,0,'cf_string','handproximity_AudioControl');
    X.LSL.MaxMSP.outlet(2) = lsl_outlet(X.LSL.MaxMSP.streamInfo(2));

    X.LSL.MaxMSP.streamInfo(3) = lsl_streaminfo(X.LSL.lib,'noisepitch','AudioControl',2,0,'cf_string','noisepitch_AudioControl');
    X.LSL.MaxMSP.outlet(3) = lsl_outlet(X.LSL.MaxMSP.streamInfo(3));

    X.LSL.MaxMSP.streamInfo(4) = lsl_streaminfo(X.LSL.lib,'overhead','AudioControl',3,0,'cf_string','overhead_AudioControl');
    X.LSL.MaxMSP.outlet(4) = lsl_outlet(X.LSL.MaxMSP.streamInfo(4));

    X.LSL.MaxMSP.streamInfo(5) = lsl_streaminfo(X.LSL.lib,'headwall','AudioControl',3,0,'cf_string','headwall_AudioControl');
    X.LSL.MaxMSP.outlet(5) = lsl_outlet(X.LSL.MaxMSP.streamInfo(5));

    X.LSL.MaxMSP.streamInfo(6) = lsl_streaminfo(X.LSL.lib,'buoys','AudioControl',2,0,'cf_string','buoy_AudioControl');
    X.LSL.MaxMSP.outlet(6) = lsl_outlet(X.LSL.MaxMSP.streamInfo(6));

    disp('Initializing LSL event outlets')
    % outlet to report speaker events as they occur
    X.LSL.MaxMSP.streamInfo(7) = lsl_streaminfo(X.LSL.lib,'speakerEvents','Event',1,0,'cf_string','speakerEvents');
    X.LSL.MaxMSP.outlet(7) = lsl_outlet(X.LSL.MaxMSP.streamInfo(7));

    % behavior events
    X.LSL.MaxMSP.streamInfo(8) = lsl_streaminfo(X.LSL.lib,'behaviorEvents','Event',1,0,'cf_string','behaviorEvents');
    X.LSL.MaxMSP.outlet(8) = lsl_outlet(X.LSL.MaxMSP.streamInfo(8));

    
    X.LSL.MaxMSP.play_sound = @(beaconSoundID, soundOn, loop, azimuth, volume, beaconEventCode) ...
        X.LSL.MaxMSP.outlet(1).push_sample({num2str(beaconSoundID), num2str(soundOn), num2str(loop), num2str(azimuth),...
        num2str(volume), beaconEventCode});
    X.LSL.MaxMSP.send_hand_proximity = @(proximityDistance, proximityAzimuth, proximityEventCode) ...
        X.LSL.MaxMSP.outlet(2).push_sample({num2str(proximityDistance), num2str(proximityAzimuth), proximityEventCode});
    X.LSL.MaxMSP.send_noise_freq = @(pitch, fooEventCode) ...
        X.LSL.MaxMSP.outlet(3).push_sample({num2str(pitch), fooEventCode});
    X.LSL.MaxMSP.send_overhead = @(which, what, eventcode) ...
        X.LSL.MaxMSP.outlet(4).push_sample({num2str(which), num2str(what), eventcode});
    X.LSL.MaxMSP.send_headwall = @(proximityDistanceHead, proximityAzimuthHead, proximityEventCodeHead) ...
        X.LSL.MaxMSP.outlet(5).push_sample({num2str(proximityDistanceHead), num2str(proximityAzimuthHead), proximityEventCodeHead});
    X.LSL.MaxMSP.play_buoy = @(buoyCode, buoyEventCode) ...
        X.LSL.MaxMSP.outlet(6).push_sample({num2str(buoyCode), buoyEventCode});
    X.LSL.MaxMSP.emitSpeakerEvent = @(event) ...
        X.LSL.MaxMSP.outlet(7).push_sample({num2str(event)});
    X.LSL.MaxMSP.emitBehaviorEvent = @(event) ...
        X.LSL.MaxMSP.outlet(8).push_sample({num2str(event)});
S
end