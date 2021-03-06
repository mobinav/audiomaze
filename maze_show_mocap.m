%function X =  mr_show_mocap(X)
% mr_show_mocap processes last sample of mr.accumulatedData into
% mr.mocap.markerPosition
%   then plot mocap points on maze 
%`  (two plot versions: vr version is slow, so can use simple
%   matlab plot. Settings in mr_maze_with_lsl)
%
%global mr
global X;
if X.numberOfFramesInAccumulatedData > 0
    if isnan(X.mocap.lastChannel) % nan for lastChannel means that all channels after firstChannel are mocap, this is useful for when the actual number is not know a priori
        mocapChannels = X.mocap.firstChannel : X.numberOfChannelsInAccumulatedData;
    else
        mocapChannels = X.mocap.firstChannel : X.mocap.lastChannel;
    end;
    
    data = X.accumulatedData(mocapChannels, X.numberOfFramesInAccumulatedData);
    channelOffset = 0;
    
    maxChan = channelOffset + floor((length(data) - channelOffset)/3) * 3;
    
    ys = double(data((1+channelOffset):3:maxChan));
    zs = double(data((2+channelOffset):3:maxChan));
    xs = double(data((3+channelOffset):3:maxChan));
%    
%     %disp([ys,-zs,xs]);
%     % compensating PhaseSpace strange rotation
% %     if ~isempty(xs)
% % %         m = makehgtform('zrotate',-pi/2);
% %          combinedXYZ = [xs ys zs ones(1, size(xs,1))'];
% % %         combinedXYZ = combinedXYZ * m;
% %         
% %         xs = -combinedXYZ(:,3);
% %         ys = combinedXYZ(:,1);
% %         zs = combinedXYZ(:,2);
% %     end;
%     
%     %invalidChannelId = find(abs(xs) + abs(ys) + abs(zs) < 10);
%     % JRI/MM call invalid channels those very close to 0,0,0
    invalidChannelId = find(abs(xs) < 0.002 | abs(ys) < 0.002 | abs(zs) < 0.002);
    invalidChannelId = union(invalidChannelId, find(isnan(xs)));
    
    %sum(abs(xs')>2)
    %invalidChannelId
    
    % put invalid points really far away, for now
    zs(invalidChannelId) = -100;
    
    zOffset = 0;
    if X.doVrPlot,
        mr_show_mocap_markers(xs, ys, zs, zOffset, 'label','off', 'markerSize', 0.1);
    end
    
    % get finger tips only
    currentHandMarkers = X.mocap.markers.rightHand(1:4);
    currentHandMarkers = [currentHandMarkers, X.mocap.markers.rightHand(6)];
 
    
    if X.mocap.doSimplePlot,
        %figure(11)
        h=findobj(gcf,'tag','markers');
        delete(h)
        ytmp = ys;
        xtmp = xs;
        bad = abs(ytmp)<0.001 & abs(xtmp)<0.001;
        ytmp(bad)=nan;
        xtmp(bad)=nan;
        plot(ytmp(X.mocap.markers.head),xtmp(X.mocap.markers.head),'.','tag','markers','markersize',20)
        plot(ytmp(currentHandMarkers),xtmp(currentHandMarkers),'r.','tag','markers','markersize',20)
        %plot(-ytmp(mr.mocap.markers.rightHand),xtmp(mr.mocap.markers.rightHand),'r.','tag','markers','markersize',20)
        plot(X.tokens.mocapLocs(:,1),X.tokens.mocapLocs(:,2),'g.','tag','markers','markersize',20)
        plot(X.tokens.endpoints(:,1),X.tokens.endpoints(:,2),'c.','tag','markers','markersize',20)
        
        %set(gca, 'XDir', 'reverse');
        set(gca, 'YDir', 'reverse');
        set(gca, 'YLim', [-4 4]);
        set(gca, 'XLim', [-4 4]);
    end;
    X.mocap.markerPosition = [1*ys, xs, zs];% / 1000; % n x 3, in meters JRI: seems already in meters
end;