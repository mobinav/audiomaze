%% setup:
clear('X');
global X;


% setup the lsl connection to the audio engine
X = maze_init_audio_engine(X);

% set angles for each individual speaker
wall_speaker_locs = [-150, 180, 150, 120, 90, 60, 30, 0,-30,-60,-90,-120];

% set the noise frequency
X.LSL.MaxMSP.send_noise_freq(3, '');

%%
for n=1:4
    for m=1:12
        X.LSL.MaxMSP.send_hand_proximity(.2, wall_speaker_locs(m), '');
        pause(2);
        X.LSL.MaxMSP.send_hand_proximity(999, wall_speaker_locs(1), '');
        pause(2);
    end
end



%%
for n=1:4
    for m=1:6

        X.LSL.MaxMSP.send_overhead(m, X.tokens.soundMap(m,2), '');
        pause(3);
    end
end



%%
for n=1:10
    for m = 1:2
         X.LSL.MaxMSP.play_flourish(m-1, '');
        pause(3);
    end
end

