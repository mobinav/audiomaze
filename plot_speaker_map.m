w=8;
h=9;

        
figure;
line([w/2, w/2], [h/2, -h/2], 'color', 'black', 'linewidth', 2)
hold
line([-w/2, -w/2], [h/2, -h/2], 'color', 'black', 'linewidth', 2)
line([w/2, -w/2], [h/2, h/2], 'color', 'black', 'linewidth', 2)
line([w/2, -w/2], [-h/2, -h/2], 'color', 'black', 'linewidth', 2)
axis([-w/2-.5 w/2+.5 -h/2-.5 h/2+1.5])

X=load('speakerMap2D.mat');
speaker_locs = X.full_map2d;
for n=1:12
    scatter(speaker_locs(n,1),speaker_locs(n,2),100, ... 
        'markeredge', [.3 .5 .7], ...
        'markerface', [.3 .7 .7], ...
        'linewidth', 2);
    text(speaker_locs(n,1)-.4, speaker_locs(n,2)-.2, sprintf('%d',n), 'fontsize', 14);

end

for n=13:20
    scatter(speaker_locs(n,1),speaker_locs(n,2),100, ... 
        'markeredge', [.7 .5 .3], ...
        'markerface', [.7 .7 .3], ...
        'linewidth', 2);
    text(speaker_locs(n,1)-.4, speaker_locs(n,2)-.2, sprintf('%d',n), 'fontsize', 14);
end
xlabel(
text(-w/2,-h/2+.5 , 'door', 'fontsize', 14);
%set(gca, 'XDir', 'reverse');
set(gca, 'YDir', 'reverse');
hold off