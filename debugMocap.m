%debug markers
frameNumber = 0;
h=[];
global X
while 1
 [sample, stamps] = X.LSL.phasespace.inlet.pull_chunk();

    if ~isempty(sample)    
        frameNumber = frameNumber+1;
        ys = double(sample(1:4:end-1,end));
        zs = double(sample(2:4:end-1,end));
        xs = double(sample(3:4:end-1,end));
        conf = double(sample(4:4:end-1,end));

        X.mocap.markerPosition = [ys, xs, zs, conf];
        
        if ~mod(frameNumber,480),
           fprintf('PS:                   [%.2f %.2f %.2f]\n',sample(1,end), sample(2,end), sample(3,end))
           fprintf('mocap.markerPosition: [%.2f %.2f %.2f]\n\n',X.mocap.markerPosition(1,1),X.mocap.markerPosition(1,2),X.mocap.markerPosition(1,3))
        end
        
        figure(11)
        hold on
        delete(h)
        h=plot(X.mocap.markerPosition(1,1),X.mocap.markerPosition(1,2),'ro');
        
    end
    drawnow
end