

if isempty(timerfind('tag','accumulatorTimer'))
    accumulatorTimer = timer('TimerFcn','try,tic;simpleTaskCb;toc;catch,end',...
      'StartDelay',0,'ExecutionMode','fixedSpacing','Period',.02,'tag','accumulatorTimer');
    start(accumulatorTimer);
end;



