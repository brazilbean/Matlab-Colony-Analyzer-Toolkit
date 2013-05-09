%% Measure Offset
% Gordon Bean, December 2012
%
% Box should be intensity data

function [sz, offset] = measure_size_and_offset( box, varargin )
    params = get_params( varargin{:} );
    params = default_param( params, 'emptyThresh', 20 );

    win = (size(box,1)-1)/2;
    
    %% Measure size
%     thresh = get_temp_thresh(box);
    thresh = fast_local_fitted('fdr',0.005).determine_threshold(box);
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

    %% Sub routines
    function it = get_temp_thresh( box )
        m = round(size(box)/2);
        mm = round( size(box)/4 );

        mid = false(size(box));
        mid(m-mm:m+mm,m-mm:m+mm) = true;

        %     it = ( prctile( box(:), 99.9 ) + parzen_mode(box(:)) ) / 2;
        %     it = ( max( box(:) ) + min( box(:) ) ) / 2;
        it = ( max( box(:) ) + median( box(~mid) ) ) / 2;

        if ( sum(box(mid)>it) / sum(mid(:)) ...
                < sum(box(~mid)>it) / sum(~mid(:)))
            % Empty spot
            it = max(box(:));
        end
    end
end