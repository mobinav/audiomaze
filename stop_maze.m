function X = stop_maze(X)
%% end game:

    delete(timerfindall);
    X.LSL.MaxMSP.play_sound(2,0,0,0,0,'OFF');
    X.LSL.MaxMSP.play_sound(1,0,0,0,0,'OFF');
    X.LSL.MaxMSP.play_sound(3,0,0,0,0,'OFF');
    X.LSL.MaxMSP.send_hand_proximity(999, 90, 'off');

   
end
    
