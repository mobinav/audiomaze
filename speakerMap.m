% this is utility code for making the speaker map. it 
%%
tmp18 = full_map2d(18,:);
full_map2d(18,:) = full_map2d(16,:)
tmp17 = full_map2d(17,:);
full_map2d(17,:) = tmp18;
full_map2d(16,:) = tmp17;
%%
save('speakerMap2D.mat', 'full_map2d');