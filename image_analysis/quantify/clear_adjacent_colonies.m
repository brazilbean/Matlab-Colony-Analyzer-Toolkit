%% Clear adjacent colonies
% Gordon Bean, May 2013

function [box, bbox] = clear_adjacent_colonies( box, bbox )
    if (nargin < 2)
        bbox = nan;
    end
    
    if size(box,3) > 1
        box = mean(box,3);
    end
    bounds = find_colony_borders_threshed( box, bbox );
    if(isnan(bbox))
        bbox = true(size(box));
    end
    
    bbox([ 1:bounds(1) bounds(2):end],:) = false;
    bbox(:, [ 1:bounds(3) bounds(4):end]) = false;

    box(~bbox) = nan;
end