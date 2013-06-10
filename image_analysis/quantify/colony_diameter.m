%% Colony Diameter - measure the diameter of the middle colony
% Gordon Bean, May 2013

function d = colony_diameter( plate, grid, ii )

    % Get box and thresholded box
    box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
    
    if (islogical(grid.thresh))
        bbox = get_box( grid.thresh, grid.r(ii), grid.c(ii), grid.win );
    else
        bbox = box > grid.thresh(ii);
    end
    
    % Get colony borders and clear adjacent colonies
    bounds = find_colony_borders_threshed( box, bbox );
    bbox([ 1:bounds(1) bounds(2):end],:) = false;
    bbox(:, [ 1:bounds(3) bounds(4):end]) = false;

    % Get colony properties
    stats = regionprops(bbox, 'Centroid', 'MajorAxisLength');
    
    % Identify the center colony
    cents = cat(1, stats.Centroid);
    w = (size(box,1)-1)/2+1;
    tmp = sum((cents - w).^2,2);
    
    % Return the diameter, or major axis length of the colony
    if isempty(stats)
        d = nan;
    else
        d = stats(argmin(tmp)).MajorAxisLength;
    end

end