



w=9;
h=10;

        
figure;
line([w/2, w/2], [h/2, -h/2], 'color', 'black', 'linewidth', 2)
hold
line([-w/2, -w/2], [h/2, -h/2], 'color', 'black', 'linewidth', 2)
line([w/2, -w/2], [h/2, h/2], 'color', 'black', 'linewidth', 2)
line([w/2, -w/2], [-h/2, -h/2], 'color', 'black', 'linewidth', 2)
axis([-w/2-.5 w/2+.5 -h/2-.5 h/2+1.5])

X=load('speakerMap2D.mat');
speaker_locs = X.full_map2d;

% 6.29 DEM:
% the ordering of the ceiling speakers is wrong up until now, and is
% changed
% for the pilot data prior to this date, put speaker 18 where 16 is, 16
% where 17 is, and 18 where 16 is. i.e. run this code:
% 
% tmp16 = speaker_locs(16,:);
% speaker_locs(16,:) = tmp17;
% tmp17 = speaker_locs(17,:);
% speaker_locs(17,:) = tmp18;
% speaker_locs(18,:) = tmp16;






for n=1:12
    scatter(speaker_locs(n,1),speaker_locs(n,2),100, ... 
        'markeredgecolor', [.3 .5 .7], ...
        'markerfacecolor', [.3 .7 .7], ...
        'linewidth', 2);
    text(speaker_locs(n,1)-.1, speaker_locs(n,2)-.5, sprintf('%d',n), 'fontsize', 14);

end

for n=13:20
    scatter(speaker_locs(n,1),speaker_locs(n,2),200, 'x', ... 
        'markeredgecolor', [.7 .5 .3], ...
        'markerfacecolor', [.7 .7 .3], ...
        'linewidth', 2);
    text(speaker_locs(n,1)+.2, speaker_locs(n,2)-.3, sprintf('%d',n), 'fontsize', 14);
end
text(-w/2-.2,-h/2-.3 , 'door', 'fontsize', 14);
title('Audiomaze Speaker Map', 'fontsize', 14, 'fontweight', 'bold')
set(gca, 'fontsize', 14); 
%set(gca, 'XDir', 'reverse');
set(gca, 'YDir', 'reverse');
axis equal
hold off