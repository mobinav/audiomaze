function mr_open_vr_world
% opens the vr world

global mr;

% close and delete any previous mr.mocap.mocapWorld
if isfield(mr, 'mocap') && isfield(mr.mocap, 'mocapWorld') && ~isempty(mr.mocap.mocapWorld)
    close(mr.mocap.mocapWorld);
    delete(mr.mocap.mocapWorld);
end;

% mocapWorld = vrworld('Z:\tools\vr\mocap\minimal_with_axis_captions', 'new');
%%mocapWorld = vrworld('\\holding\nima\tools\vr\mocap\minimal_with_axis_captions', 'new');

%%%mocapWorld = vrworld([pwd,'\vr\mocap\minimal_with_axis_captions'], 'new');
mocapWorld = vrworld(['E:\Demo\vr\mocap\minimal_with_axis_captions'], 'new');

open(mocapWorld);

mr.mocap.mocapWorld = mocapWorld;

% mr.mocap.afterInitCallback is a callbck (function or script as string) to be executed after mocap vrml figure
% is created

if~isfield(mr.mocap, 'afterInitCallback')
    mr.mocap.afterInitCallback = '';
end;