function mz_lns = makeSimpleMaze(code)
% mz_lns = makeSimpleMaze(code)
%
% make simple mazes from Levy-Tzedek S, Maidenbaum S, Amedi A, Lackner J (2016)
%Aging and Sensory Substitution in a Virtual Navigation Task. PLoS ONE
%11(3): e0151593. doi:10.1371/journal.pone.0151593
%
% e.g. "A"
% x
% x
% x x x
%     x
%     x

n_row=5;
n_col=5;
wallThickness = 0.1;

maze = zeros(n_row*n_col,2); %25 squares, right/bottom
switch upper(code),
  case 'A',
    maze(1,1)=1;
    maze(6,1)=1;
    maze(7,2)=1;
    maze(8,2)=1;
    maze(11,2)=1;
    maze(12,2)=1;
    maze(13,1)=1;
    maze(17,1)=1;
    maze(18,1)=1;
    maze(22,1)=1;
    maze(23,1)=1;
    
%   case 'B',
%     maze(1,2)=1;
%     maze(2,2)=1;
%     maze(4,2)=1;
%     maze(5,2)=1;
%     
%     maze(7,1)=1;
%     maze(8,1)=1;
%     maze(12,1)=1;
%     maze(13,1)=1;
%     maze(17,1)=1;
%     maze(18,1)=1;
%     maze(22,1)=1;
    
  case 'B',
    maze(2,1)=1;
    maze(3,1)=1;
    maze(7,1)=1;
    maze(8,1)=1;
    maze(12,1)=1;
    
    maze(13,1)=1;
    maze(16,2)=1;
    maze(17,1:2)=1;
    maze(18,1)=1;
    maze(19,2)=1;
    maze(20,2)=1;

  case 'C',
    
  case 'D',
    maze(1,1)=1;
    maze(6,1)=1;
    maze(7,2)=1;
    maze(8,2)=1;
    maze(12,2)=1;
    maze(13,1:2)=1;
    maze(16,1)=1;
    maze(21,1)=1;
    
  case 'E',
    maze(1,1)=1;
    maze(3,1)=1;
    maze(4,1)=1;
    maze(6,1)=1;
    maze(8,1)=1;
    maze(9,1)=1;
    maze(11,1)=1;
    maze(12,2)=1;
    maze(13,1:2)=1;
    maze(14,1)=1;
    maze(16:19,2)=1;
    maze(19,1)=1;
    
  otherwise
   error('unknown maze code') 
end

[~,mz_lns] = make_maze_polygons_nr(n_row,n_col, wallThickness, maze(:,2),maze(:,1));