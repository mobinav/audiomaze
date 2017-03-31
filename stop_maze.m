% stop_maze emergency stops the running maze, turns all sounds off
global X;

fprintf(2,'Stopping maze...')
if ~isempty(timerfindall)
    stop(timerfind('tag','accumulatorTimer'));
    delete(timerfind('tag','accumulatorTimer'));
    fprintf(2,'Disable timer...');
end

if isfield(X,'LSL')
    X.LSL.MaxMSP.play_sound(2,0,0,0,0,'OFF');
    X.LSL.MaxMSP.play_sound(1,0,0,0,0,'OFF');
    X.LSL.MaxMSP.play_sound(3,0,0,0,0,'OFF');
    X.LSL.MaxMSP.send_hand_proximity(999, 90, 'off');
    X.LSL.MaxMSP.send_headwall(999, 90, 'off');
    fprintf(2,'Sounds off...');

    lib = X.LSL.lib;
    X = rmfield(X,'LSL');
    clear lib
    fprintf(2,'LSL closed...');
end
fprintf(2,'Done.\n');

