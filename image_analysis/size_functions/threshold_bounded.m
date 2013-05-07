%% Threshold Bounded
% Colony Size Measuring Method
% Gordon Bean, March 2013

function [sz, bbox] = threshold_bounded( plate, grid, ii )
    
    box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
    
    bounds = find_colony_borders( box, grid.thresh(ii) );
    
    if (islogical(grid.thresh))
        bbox = get_box( grid.thresh, grid.r(ii), grid.c(ii), grid.win );
    else
        bbox = box > grid.thresh(ii);
    end
    bbox([ 1:bounds(1) bounds(2):end],:) = false;
    bbox(:, [ 1:bounds(3) bounds(4):end]) = false;

    sz = sum(bbox(:));

end

    