
%use this loop for debugging--the timer makes it hard to debug because it
%doesn't show error properly

% dbstop if error
% disp('non-timer version')
% while 1,
%     tic
%     simpleTaskCb
%     toc
% end

%use this for normal running
if isempty(timerfind('tag','accumulatorTimer'))
%     accumulatorTimer = timer('TimerFcn','try,tic;simpleTaskCb;toc;catch,lasterr,end',...
%         'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
    accumulatorTimer = timer('TimerFcn','tic;simpleTaskCb;toc','ErrorFcn','disp(''Whoops! To debug go to SimpleTaskMainLoop.''); keyboard',...
        'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
    start(accumulatorTimer);
end