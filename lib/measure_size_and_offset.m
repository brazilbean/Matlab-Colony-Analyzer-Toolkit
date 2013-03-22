%% Measure Offset
% Gordon Bean, December 2012
%
% Box should be intensity data

function [sz, offset] = measure_size_and_offset( box, thresh, varargin )
    params = get_params( varargin{:} );
    params = default_param( params, 'emptyThresh', 20 );

    win = (size(box,1)-1)/2;
    
    thresh = max_min_mean(box);
    bbox = imclearborder(box > thresh);
    
    stats = regionprops( bbox, 'area','centroid' );
    
    cents = cat(1,stats.Centroid);
    cents = bsxfun(@minus, cents, win+1 );
    areas = cat(1,stats.Area);
    
    %% Measure offset
    ci = find( sqrt(sum( cents.^2, 2 )) < win/2 );
    if (numel(ci) > 1)
        [~,mi] = max( areas(ci) );
        ci = ci(mi);
    end
    
    if (isempty(ci))
        sz = nan;
        offset = nan;
    else
        sz = areas(ci);
        offset = cents(ci,:);
    end

end