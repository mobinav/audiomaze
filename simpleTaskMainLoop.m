% simpleTaskMainLoop -- run the actual maze
global X
DEBUG = X.debugMaze; %the while loop below makes debugging easier

clear simpleTaskCb %needed to reset persistent variables

if DEBUG
    %use this loop for debugging--the timer makes it hard to debug because it
    %doesn't show errors properly
    dbstop if error
    disp('DEBUG: non-timer version')
    while 1
        tic
        simpleTaskCb
        ttt=toc;
        fprintf(' DEBUG! %.2f ms\n',ttt*1000)
    end
else
    %use this for normal running
    if isempty(timerfind('tag','accumulatorTimer'))
        %     accumulatorTimer = timer('TimerFcn','try,tic;simpleTaskCb;toc;catch,lasterr,end',...
        %         'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
        accumulatorTimer = timer('TimerFcn','tic;simpleTaskCb;ttt=toc;fprintf('' %.2f ms\n'',ttt*1000)','ErrorFcn','disp(''Whoops! To debug go to SimpleMaze.m and set debugMaze=true.''); keyboard',...
            'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
        %profile on % discovered wasted calls to pdist in
        %audioMaze.findNearestPoints. Other findings make less sense.
        start(accumulatorTimer);
    else
        warning('Existing timer found, doing nothing. Run stop_maze first.')
    end
end