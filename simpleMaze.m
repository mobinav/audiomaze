function simpleMaze()
% function for initiating a simple maze session
% @param which    : upper case character A-F indicating which maze to build
% @param trial_no : which run through the maze (1-3)

global which_maze;
global subject_id;
%global random_seed;
global trial_number;
global X;
global mazeStopped;

is_practice = false;

subject_id = input('Enter subject ID: ','s');

which_maze = whichMazePrompt();
if which_maze == 'P'
    which_maze = 'A'
    is_practice = true;
end

if ~is_practice,
    trial_number = whichTrialPrompt();
    
    str = bonusPrompt();
    if str=='Y',
        disp('Resetting bonus to 0')
        f = fopen([subject_id '_bonusFile'], 'W');
        fprintf(f, '%f', 0.0);
        fclose(f);
    end
    
    fprintf('%s: Initiating maze %s for trial %d\n', subject_id, which_maze, trial_number);
    simpleInitScrpt;
        
    disp('Maze initiated. Press any key to begin.')
    pause
    
    X.LSL.emitInfo(which_maze, random_seed, trial_number);
    
    simpleTaskMainLoop;
    
% special case of practice maze: 
else
    fprintf('Initiating practice maze %s', which_maze);
    simpleInitScrpt;
    
    disp('Maze initiated. Press any key to begin.')
    pause
    
    simpleTaskMainLoop;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = whichMazePrompt()
prompt = 'Enter maze type A-F, or P for practice: ';
choices = 'ABCDEFP';
while true,
    str = upper(input(prompt,'s'));
    str = str(1);
    if any(str==choices),
        break
    else
        fprintf(2,'Invalid selection. Try again.\n')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trial = whichTrialPrompt()
prompt = 'Enter trial number 1-4: ';
trial = 0;
while (isnan(trial) || trial < 1 || trial > 4),
    str = input(prompt,'s');
    trial = floor(str2double(str));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = bonusPrompt()
bonus = 0;
prompt = 'Initiate new bonus record? Y/N [N]: ';
str = upper(input(prompt,'s'));
if isempty(str)
    str = 'N';
end
