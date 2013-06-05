%% Left edge - a colony size function based on left edge position
% Gordon Bean, May 2013

function [sz, box] = left_edge( plate, grid, ii )

    % Get box
    box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
    
    % Threshold box
    if (islogical(grid.thresh))
        bbox = get_box( grid.thresh, grid.r(ii), grid.c(ii), grid.win );
    else
        bbox = box > grid.thresh(ii);
    end
    
    % Bounding box on center colony
    bounds = find_colony_borders_threshed( box, bbox );
    bbox([ 1:bounds(1) bounds(2):end],:) = false;
    bbox(:, [ 1:bounds(3) bounds(4):end]) = false;
    
    % Measure position of left edge
    sz = find(any(bbox,1), 1, 'first');
    if isempty(sz)
        sz = nan;
    end

end