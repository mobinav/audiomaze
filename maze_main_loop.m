function X = maze_main_loop(X)
    %% MAIN LOOP
    %  % define and then start the main timer
    if isempty(timerfind('tag','accumulatorTimer'))
        accumulatorTimer = timer('TimerFcn','try,tic;X=maze_accumulate_lsl(X);X=maze_show_mocap(X);X=maze_lsl(X);toc;catch,end',...
          'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');

        start(accumulatorTimer);
    end;
end