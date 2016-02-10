function roomWallCollection = vr_draw_maze(mocapWorld,am)
    
    roomWallCollection = vrObjectCollection;    
    for n=1:4
        roomWallCollection = roomWallCollection.add(vrVerticalWall(mocapWorld, am.roomWalls(n, 1:2), am.roomWalls(n, 3:4), 0.3,0.05, true));     

    end

%     for i=1:4
%         roomWallCollection.object{i}.prism.polygon(3, 1:2) = [-10000 -10000];
%         roomWallCollection.object{i}.prism.polygon(3, 3:4) = [10000 10000];
%     end;

    for i=1:size(am.mazeWalls,1)
        roomWallCollection = roomWallCollection.add(vrVerticalWall(mocapWorld, am.mazeWalls(i, 1:2), am.mazeWalls(i, 3:4) , 1, .2, true));
    end;


end