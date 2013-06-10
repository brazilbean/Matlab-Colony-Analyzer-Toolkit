%% Center Spot Method
% Colony Size Measuring Method
% Gordon Bean, December 2012

function [sz, box] = center_spot_method( box, thresh )
    box = box > thresh;
    stats = regionprops( box , 'area','centroid');
    areas = cat(1, stats.Area);
    cents = cat(1, stats.Centroid);

    win = (size(box,1)-1) / 2;
    
    areas = areas( sqrt(sum((cents-win).^2,2)) < win/2 );
    
    if (isempty(areas))
        sz = 0;
    else
        sz = max(areas);
    end
end