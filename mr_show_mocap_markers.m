% TODO distinguish head and hand markers by color

function mr_show_mocap_markers(xs, ys, zs, zOffset, varargin)

global mr;

inputOption = finputcheck(varargin, ...
    { 'label'         'string'  { 'on' 'off' }  'off'; ...
    'markerSize'       'real'     [0 10]    0.1 ; ...
    });

if isstr(inputOption)
    error(inputOption);
end

global wallCollection;
persistent figureHandle scale numberOfMarkers lastLabelOption lastMarkerSize lastNumberOfMarkers 

% the first time variales are accessed
if isempty(lastLabelOption)
    lastLabelOption = inputOption.label;
end;

if isempty(lastMarkerSize)
    lastMarkerSize = inputOption.markerSize;
end;


if isempty(figureHandle) || ~isvalid(figureHandle) || (~strcmp(lastLabelOption, inputOption.label) || lastMarkerSize ~= inputOption.markerSize)
    
    % if the handle is valid, it means that we have to close the figure and
    % open a new one to use updated options (markersize or labels)
    if ~isempty(figureHandle) && isvalid(figureHandle)
        close(figureHandle);
    end;
    
    mr_open_vr_world
   
    % mr.mocap.afterInitCallback is a callbck (function or script as string) to be executed after mocap vrml figure
    % is created
    if ~isempty(mr.mocap.afterInitCallback)
        eval(mr.mocap.afterInitCallback);
    end;
    
    mr.mocap.roomWallCollection = vr_draw_maze(mr.mocap.mocapWorld, mr.am); 
    
    % create a vrml display figure
    figureHandle = view(mr.mocap.mocapWorld);
    vrdrawnow;
    
    % place markers at 0,0,0
    numberOfMarkers = size(xs, 1);
    %markerSize = 0.1;
    
    mr.mocap.mocapMarker = vrObjectCollection;
    
    for i=1:numberOfMarkers
        mr.mocap.mocapMarker = mr.mocap.mocapMarker.add(vrSphere(mr.mocap.mocapWorld, [0 0 0], inputOption.markerSize, true, [0.6 0.9 0.6]));
       
        if strcmp(inputOption.label, 'on')
            mr.mocap.markerTextTransform{i} =  vr_add_text_billboard(mr.mocap.mocapWorld, [ 0 0 0], num2str(i), 0.2);
        end;
    end;
    
    % default scale, assuming data is in mm
    scale = 1/1000;
    scale = 1; %JRI data now in m everywhere
    
    %  zOffset  = - min(zs(:));
end;

for i=1:numberOfMarkers
    %markerTransform{i}.translation = scale * [xs(i) ys(i) zOffset + zs(i)];
    mr.mocap.mocapMarker.object{i}.transformNode.translation = scale * [xs(i) ys(i) zOffset + zs(i)];
    
    if strcmp(inputOption.label, 'on')
        mr.mocap.markerTextTransform{i}.translation = mr.mocap.mocapMarker.object{i}.transformNode.translation;
    end;
end;

vrdrawnow;

% to see if they have changed next time the function runs
lastLabelOption = inputOption.label;
lastMarkerSize = inputOption.markerSize;