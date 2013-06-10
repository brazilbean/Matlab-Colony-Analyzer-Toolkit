%% 4.5 Sigma Method
% Gordon Bean, February 2013

function [sz, bb, info] = sigma45_method( box, it, varargin )
    params = get_params(varargin{:});
    params = default_param( params, 'fullthresh', 0.75 );
    params = default_param( params, 'sigfact', 4.5 );
    
    FTHRESH = params.fullthresh;
    SIGFACT = params.sigfact;
    
    % Find colony borders 
    bo = find_colony_borders( box );
    b = box(bo(1) : bo(2),bo(3) : bo(4));
    
    % Get intensity threshold (it) estimate
    if (nargin < 2), it = nan; end
    if (isnan(it))
        % Estimate it using max-min-mean
        it = estimate_intensity_threshold( box );
        if (nargout > 2)
            info.it0 = it;
        end
    end
    
    % Perform correction
    fullness = sum( b(:) > it ) / numel(b);
    if (fullness > FTHRESH)
        % Full spot - don't use 4.5sigma correction
        
    else
        % Sparse spot - use correction
%         pm = parzen_mode( b(b < it) );
%         tmp = b(b < pm) - pm;
        
        pm = parzen_mode( box(box < it) );
        tmp = box(box < pm) - pm;
        st = std( [tmp; -tmp] );
        
        % Use min to protect against freak cases
        it = min( it, pm + SIGFACT*st );

    end
    
    % Measure colony size
    stats = regionprops( b > it, 'area' );
    sz = max( cat(1, stats.Area) );
    if (isempty(sz))
        sz = 0;
    end
    
    % Return thresholded box
    if (nargout > 1)
        bb = false(size(box));
        bb(bo(1) : bo(2), bo(3) : bo(4)) = b > it;
    end
    if (nargout > 2)
        info.stats = stats;
        info.fullness = fullness;
        info.bo = bo;
        if ~(fullness > FTHRESH), info.pm = pm; info.st = st; end
        info.it = it;
    end
end