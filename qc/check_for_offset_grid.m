%% Check for offset grid
% Gordon Bean, December 2012

function check = check_for_offset_grid( data, dims )

    d2 = reshape(data, [size(data,1), dims]);
    
    [r,~] = find(sum(d2(:,[1 end],:)<50,3)>dims(1));
    [c,~] = find(sum(d2(:,:,[1 end])<50,2)>dims(2));

    check = [r; c];

end

%%
% imagedir = 'data/96_0hrs/2012_12_18/';
% [data, files] = load_colony_sizes( imagedir );
% 
% %%
% hist(data(:),50)
% 
% %%
% d2 = reshape(data, [size(data,1), 8 12]);
% 
% %%
% hist(sum(d2(:,:,end)>50, 2),50)
% 
% ff = find(sum(d2(:,:,end)>50,2)<8)
% 
% %%
% ii =1 ;
% view_plate_image( files(ff(ii)), 'showGrid', false, 'applyThreshold', false )
% d2(ff(ii),:,end)
% 
% %%
% plate = crop_background(mean(imread( files{ff(ii)}(1:end-7)),3));
% grid = load( [files{ff(ii)}(1:end-7) '.info.mat'] );
% 
% %%
% grid.thresh
% 
% %%
% rr = 7;
% cc = 12;
% box = get_box( plate, grid.r(rr,cc), grid.c(rr,cc), grid.win );
% 
% %%
% imagesc(box)
% % imagesc( box > grid.thresh(rr,cc) )
% 
% hold on; scatter( grid.win+1, grid.win+1, 50, 'r','filled' ); hold off;
% 
% %%
% center_spot_method( box, grid.thresh(rr,cc) )
% 
% %%

%%
