%% Colony Width
% Colony Size Measuring Method
% Gordon Bean, March 2013

function [sz, bbox] = colony_width( plate, grid, ii )
    
    box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
    
    if (islogical(grid.thresh))
        bbox = get_box( grid.thresh, grid.r(ii), grid.c(ii), grid.win );
    else
        bbox = box > grid.thresh(ii);
    end
    bounds = find_colony_borders_threshed( box, bbox );
    bbox([ 1:bounds(1) bounds(2):end],:) = false;
    bbox(:, [ 1:bounds(3) bounds(4):end]) = false;

    sz = sum(bbox(grid.win+1,:));

end

    