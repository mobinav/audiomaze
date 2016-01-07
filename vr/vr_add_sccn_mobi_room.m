function roomWallCollection = vr_add_sccn_mobi_room(myworld, h, w)

roomWallCollection = vrObjectCollection;
roomWidth = w;
roomHeight = h;
roomWallCollection = roomWallCollection.add(vrVerticalWall(myworld, [-roomWidth, -roomWidth]/2, [roomHeight, -roomHeight]/2, 0.3,0.05, true));
roomWallCollection = roomWallCollection.add(vrVerticalWall(myworld, [-roomWidth, roomWidth]/2, [-roomHeight, -roomHeight]/2, 0.3,0.05, true));
roomWallCollection = roomWallCollection.add(vrVerticalWall(myworld, [-roomWidth, roomWidth]/2, [roomHeight, roomHeight]/2, 0.3,0.05, true));
roomWallCollection = roomWallCollection.add(vrVerticalWall(myworld, [roomWidth, roomWidth]/2, [roomHeight, -roomHeight]/2, 0.3,0.05, true));

% extend the geometrical representation of walls to extend from very low to
% very high and cover the whole height of the room
for i=1:4
    roomWallCollection.object{i}.prism.polygon(3, 1:2) = [-10000 -10000];
    roomWallCollection.object{i}.prism.polygon(3, 3:4) = [10000 10000];
end;