%% end game:
global mr;
delete(timerfindall);
mr.LSL.MaxMSP.play_sound(2,0,0,0,0,'OFF');
mr.LSL.MaxMSP.play_sound(1,0,0,0,0,'OFF');
mr.LSL.MaxMSP.play_sound(3,0,0,0,0,'OFF');
mr.LSL.MaxMSP.send_hand_proximity(999, 90, 'off');
clear('mr');
clf(11);
hold off;