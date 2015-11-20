%%
maze = [1,0,;  0, 1; 1, 0; 0, 0; 1, 1; 1, 0; 0, 1; 0, 1; 1, 0;];
%%
f = mazeBuilder(3,3,maze);
%%
am = audioMaze(1, 1, 3, 3, f);
figure;
am.plotMaze;