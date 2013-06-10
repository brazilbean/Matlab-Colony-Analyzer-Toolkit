%% Colony Box Method
% Colony Size Measuring Method
% Gordon Bean, December 2012

function [sz, box] = colony_box_method( box, thresh )
    
    bounds = find_colony_borders( box, thresh );
    box = box > thresh;
    box([ 1:bounds(1) bounds(2):end],:) = false;
    box(:, [ 1:bounds(3) bounds(4):end]) = false;

    sz = sum(box(:));

end

    