%%
global mr;


% setup the lsl connection to the audio engine
maze_init_audio_engine();

% set angles for each individual speaker
wall_speaker_locs = [-30, 0,30,60, 90,120,150,180,-150,-120,-90,-60];

% set the noise frequency
mr.LSL.MaxMSP.send_noise_freq(3, '');

%%
for m=1:4 % do it four times
    random_ref = randperm(12);
    % set the filter frequency to the middle pitch
    for n=1:12
        mr.LSL.MaxMSP.emitSpeakerEvent(random_ref(n));
        mr.LSL.MaxMSP.send_hand_proximity(.2, wall_speaker_locs(random_ref(n)), '');
        pause(2.5);
        mr.LSL.MaxMSP.send_hand_proximity(999, wall_speaker_locs(random_ref(n)), '');
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
speakerLocs = [1,4;2,2;2,5;4,1; 4,4;5,2]; % number corresponds to maze panel: r, c
tokenMap = [1,1;2,2;3,3;4,4;5,5;6,6];
% create the tokens object
mr.tokens = mazeTokens(am, speakerLocs, tokenMap);
for n=1:6
    mr.tokens.active(n) = n;
end

%%
for m=1:8
    random_ref = randperm(8);

    for n=1:8
        ref = random_ref(n);
        if ref==7
            mr.LSL.MaxMSP.play_buoy(0, 'foo'); 
        elseif ref==8
            mr.LSL.MaxMSP.play_buoy(1, 'foo'); 
        else
            mr.LSL.MaxMSP.send_overhead(ref, mr.tokens.soundMap(ref,2), '');
        end
         mr.LSL.MaxMSP.emitSpeakerEvent(random_ref(n)+12); 
        pause(4.5);
    
    end    
end


    