%%
clear('X');
global X;


% setup the lsl connection to the audio engine
X = maze_init_audio_engine(X);

% set angles for each individual speaker
% mapped to the phasespace orientation, vertically flipped in relation to 
% maxmsp orientation
wall_speaker_locs = [-150, 180, 150, 120, 90, 60, 30, 0,-30,-60,-90,-120];

% set the noise frequency
X.LSL.MaxMSP.send_noise_freq(3, '');

%%
for m=1:4 % do it four times
    random_ref = randperm(12);
    % set the filter frequency to the middle pitch
    for n=1:12
        X.LSL.MaxMSP.emitStimulusEvent(random_ref(n));
        X.LSL.MaxMSP.send_hand_proximity(.2, wall_speaker_locs(random_ref(n)), '');
        pause(2.5);
        X.LSL.MaxMSP.send_hand_proximity(999, wall_speaker_locs(random_ref(n)), '');
        pause(3.5); 
    end

end







%% overheads

% use an empty maze to map the overhead speakers to
mz_lns = importdata('./mazes/empty.mat');
w = 6;
h = 6.5;
am = audioMaze(h, w, 5, 5, mz_lns);
% setup the overhead speker sounds
speakerLocs = [1,4;2,2;2,5;4,1;4,4;5,2]; % number corresponds to maze panel: r, c
tokenMap = [1,1;2,2;3,3;4,4;5,5;6,6];
% create the tokens object
X.tokens = mazeTokens(am, speakerLocs, tokenMap);
for n=1:6
    X.tokens.active(n) = n;
end

%%
for m=1:8
    random_ref = randperm(8);

    for n=1:8
        ref = random_ref(n);
        if ref==7
            X.LSL.MaxMSP.play_buoy(0, 'foo'); 
        elseif ref==8
            X.LSL.MaxMSP.play_buoy(1, 'foo'); 
        else
            X.LSL.MaxMSP.send_overhead(ref, X.tokens.soundMap(ref,2), '');
        end
         X.LSL.MaxMSP.emitStimulusEvent(random_ref(n)+12); 
        pause(4.5);
    
    end    
end

%%
clear all



    