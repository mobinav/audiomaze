function newName = vr_new_name_based_on(world, baseName)
nodesInWorld = nodes(world);

% get all node names
nameOfNodesInWorld = cell(1,length(nodesInWorld));

for i=1:length(nodesInWorld)
    nameOfNodesInWorld{i} = get(nodesInWorld(i),'name');
end;

for counter = 1:100000
    if ~nameExist([baseName num2str(counter)], nameOfNodesInWorld)
        newName = [baseName num2str(counter)];
        return;
    end;
end;

fprintf('Name could not be found after many attempts!\n');



function result = nameExist(name, nameOfNodesInWorld)

result = any(strmatch(name, nameOfNodesInWorld));% see if any name in the world contains 'name' as sub-string. This is to prevent any similar names in the world.