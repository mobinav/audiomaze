%% MAIN LOOP 
%  % define and then start the main timer
if isempty(timerfind('tag','accumulatorTimer'))
    accumulatorTimer = timer('TimerFcn','try,tic;maze_accumulate_lsl;maze_show_mocap;maze_lsl;toc;catch,end',...
      'StartDelay',0,'ExecutionMode','fixedSpacing','Period',0.06,'tag','accumulatorTimer');

    start(accumulatorTimer);
end;