global mr;  

addpath(genpath('C:\DEVEL\labstreaminglayer\LSL\liblsl-Matlab'));
if isfield(mr,'LSL'), mr = rmfield(mr,'LSL'); end
mr.LSL.lib = lsl_loadlib();

% while we are at it, initiallize the current clock time
mr.time_was = lsl_local_clock(mr.LSL.lib);
%init outlets to MAX
disp('Initializing LSL outputs to MAX/MSP')

mr.LSL.MaxMSP.streamInfo(1) = lsl_streaminfo(mr.LSL.lib,'fileplay','AudioControl',6,0,'cf_string','fileplay_AudioControl');
mr.LSL.MaxMSP.outlet(1) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(1));

mr.LSL.MaxMSP.streamInfo(2) = lsl_streaminfo(mr.LSL.lib,'handproximity','AudioControl',3,0,'cf_string','handproximity_AudioControl');
mr.LSL.MaxMSP.outlet(2) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(2));

mr.LSL.MaxMSP.streamInfo(3) = lsl_streaminfo(mr.LSL.lib,'noisepitch','AudioControl',2,0,'cf_string','noisepitch_AudioControl');
mr.LSL.MaxMSP.outlet(3) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(3));

mr.LSL.MaxMSP.streamInfo(4) = lsl_streaminfo(mr.LSL.lib,'overhead','AudioControl',3,0,'cf_string','overhead_AudioControl');
mr.LSL.MaxMSP.outlet(4) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(4));

mr.LSL.MaxMSP.streamInfo(5) = lsl_streaminfo(mr.LSL.lib,'headwall','AudioControl',3,0,'cf_string','headwall_AudioControl');
mr.LSL.MaxMSP.outlet(5) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(5));

mr.LSL.MaxMSP.streamInfo(6) = lsl_streaminfo(mr.LSL.lib,'buoys','AudioControl',2,0,'cf_string','buoy_AudioControl');
mr.LSL.MaxMSP.outlet(6) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(6));

mr.LSL.MaxMSP.streamInfo(7) = lsl_streaminfo(mr.LSL.lib,'speakerEvents','Event',1,0,'cf_string','speakerEvents');
mr.LSL.MaxMSP.outlet(7) = lsl_outlet(mr.LSL.MaxMSP.streamInfo(7));
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
mr.LSL.MaxMSP.send_overhead = @(which, what, eventcode) ...
    mr.LSL.MaxMSP.outlet(4).push_sample({num2str(which), num2str(what), eventcode});
mr.LSL.MaxMSP.send_headwall = @(proximityDistanceHead, proximityAzimuthHead, proximityEventCodeHead) ...
    mr.LSL.MaxMSP.outlet(5).push_sample({num2str(proximityDistanceHead), num2str(proximityAzimuthHead), proximityEventCodeHead});
  mr.LSL.MaxMSP.play_buoy = @(buoyCode, buoyEventCode) ...
    mr.LSL.MaxMSP.outlet(6).push_sample({num2str(buoyCode), buoyEventCode});
  mr.LSL.MaxMSP.emitSpeakerEvent = @(event) ...
    mr.LSL.MaxMSP.outlet(7).push_sample({num2str(event)});