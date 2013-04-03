%% Threshold Bounded
% Colony Size Measuring Method
% Gordon Bean, March 2013

function [sz, box] = threshold_bounded( plate, grid, ii )
    
    box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
    
    bounds = find_colony_borders( box, grid.thresh(ii) );
    
    box = box > grid.thresh(ii);
    box([ 1:bounds(1) bounds(2):end],:) = false;
    box(:, [ 1:bounds(3) bounds(4):end]) = false;

    sz = sum(box(:));

end

    