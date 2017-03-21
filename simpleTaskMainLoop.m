% simpleTaskMainLoop -- run the actual maze
DEBUG = true; %the while loop below makes debugging easier

if DEBUG
    %use this loop for debugging--the timer makes it hard to debug because it
    %doesn't show error properly
    dbstop if error
    disp('non-timer version')
    while 1
        tic
        simpleTaskCb
        ttt=toc;
        fprintf('DEBUG! %.2f ms\n',ttt*1000)
    end
else
    %use this for normal running
    if isempty(timerfind('tag','accumulatorTimer'))
        %     accumulatorTimer = timer('TimerFcn','try,tic;simpleTaskCb;toc;catch,lasterr,end',...
        %         'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
        accumulatorTimer = timer('TimerFcn','tic;simpleTaskCb;ttt=toc;fprintf(''%.2f ms\n'',ttt*1000)','ErrorFcn','disp(''Whoops! To debug go to SimpleTaskMainLoop and set DEBUG=true.''); keyboard',...
            'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
        start(accumulatorTimer);
    else
        warning('Existing timer found, doing nothing. Try stop_maze')
    end
end