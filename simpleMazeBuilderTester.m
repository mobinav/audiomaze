% maze dimensions
n_rows = 5;
n_cols = 5;

% room dimensions
w = 6;
h = 6.5;


which_maze = 'F';
mz_lns = makeSimpleMazeRev(which_maze);

maze = audioMaze(h,w,n_rows, n_cols, mz_lns);
maze.plotMaze();

%%
f = figure(1);
mazes = {'A', 'B', 'C', 'D', 'E', 'F'}
for n=1:6
    
    mz_lns = makeSimpleMazeRev(mazes{n});
    maze = audioMaze(h,w,n_rows, n_cols, mz_lns);
    clf(maze.fig_handle);
    
    figure(f)
    subplot(3,2,n)
    maze.plotMaze();
  
    if strcmp(mazes(n), 'A')
        speakerLocs = [1,3; ... % start square
                       5,3]; % end square
        
    end
    if strcmp(mazes(n), 'B')
        speakerLocs = [4,1; ... % start square
            1,4]; % end square
        
    end
    if strcmp(mazes(n), 'C')
        speakerLocs = [1,1; ... % start square
            1,4]; % end square
        
    end
    if strcmp(mazes(n), 'D')
        speakerLocs = [1,1; ... % start square
            4,5]; % end square
        
    end
    if strcmp(mazes(n), 'E')
        speakerLocs = [1,3; ... % start square
            5,1;5,5]; % end square
        
    end
    if strcmp(mazes(n), 'F')
        speakerLocs = [1,3; ... % start square
            3,1;3,5;5,3]; % end square
        
    end
    
    % use the tokens (these should be more abstract, but it works ok for now)
    tokens = mazeTokens(maze, speakerLocs, []);
    hold
    plot(tokens.mocapLocs(1,1), tokens.mocapLocs(1,2), '.', 'color', [.5 .5 .9], 'markersize',30, 'linewidth', 3);
    plot(tokens.mocapLocs(2:end-2,1), tokens.mocapLocs(2:end-2,2), '.', 'color', [.9 .5 .5], 'markersize',30, 'linewidth', 3);

    set(gca, 'YLim', [-4 4]);
    set(gca, 'XLim', [-4 4]);
    title(sprintf('Maze %s', mazes{n}));
end