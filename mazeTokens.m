% class definition for overhead audio tokens
% code by David Medine, SCCN
% begun 3/2/2016

classdef mazeTokens
    properties
        mazeLocs      % locations (in panels) of the tokens
        mocapLocs     % locations in mocap space of the tokens
        endpoints     % beginning and end of the maze
        wired         % shows which tokens are wired to produce sound
        active        % shows which tokens are active 
        count         % number of tokens
        soundMap      % map to indeces of which sound to send
    end
    
    
    methods
        
        % constructor
        % maze : an audioMaze object with all the dimsensional info we
        %        need
        %
        % speakerLocs : an array of physical speaker locations in panel
        %               number (entrance is 1, upper left hand corner, 
        %               and exit is the last number, lower right hand corner)
        function obj = mazeTokens(maze, locs, map)
            
            obj.mazeLocs = locs;
            rows = maze.mbyn(1);
            cols = maze.mbyn(2);
            % height and width of a panel in mocap space
            panel_h = maze.roomDims(1)/rows;
            panel_w = maze.roomDims(2)/cols;
            
            
            % NOTE: the -1 multiply on the 'x-axis' is to conform with
            % phasespace's notion of the room coordinates
            % entrance location
            obj.endpoints(1,:) = [-(maze.roomDims(2)*-.5+panel_w*.5), maze.roomDims(1)*-.5];
            % exit location
            obj.endpoints(2,:) = [-(maze.roomDims(2)*.5 - panel_w*.5), maze.roomDims(1)*.5];

          
            
            %obj.mocapLocs
            locs_norm(:,2) = (((locs(:,1)/rows) - 1/rows) - .5)* maze.roomDims(1); % check for this with assymetrical dimensions 
            locs_norm(:,1) = (((locs(:,2)/cols) - 1/cols) - .5)* maze.roomDims(2); 

            for n=1:length(locs(:,1))
                obj.mocapLocs(n,:) = [-locs_norm(n,1) - panel_w*.5, locs_norm(n,2) + panel_h*.5];
                obj.count = obj.count + 1;
                obj.wired(n) = 0; % set to disconnected
            end            
            obj.active = zeros(size(obj.wired)); % set to innactive
            
  
        


            % tack these on to the beginning and ending tokens
            for n=1:length(map(:,1)) % number of rows 
                obj.soundMap(n,:) = map(n,:);    
                obj.wired(map(n,1)) = 1; % each of these is now wired
                obj.active(map(n,1)) = 1; % and active

            end

        end 
    end
    
end