%% Compute local thresholds
% Gordon Bean, March 2013

function its = compute_local_thresholds( plate, grid, varargin )
    params = get_params(varargin{:});
    params = default_param( params, 'thresholdmethod', local_fitted() );
    params = default_param( params, 'smoothing', true );
    
    if (~isobject(params.thresholdmethod) && ...
           ~stcmp(superclasses(params.thresholdmethod),'threshold_method'))
        error(['Method parameter should indicate' ...
            ' a threshold_method subclass']);
    end
    
    % Iterate over grid positions
    % - get the box
    % - estimate the size
    its = nan(grid.dims);
    for rr = 1 : grid.dims(1)
        for cc = 1 : grid.dims(2)
            box = params.thresholdmethod.get_colony_box ...
                ( plate, grid, rr, cc );
            its(rr,cc) = params.thresholdmethod.determine_threshold(box);
        end
    end
    
    % Smoothing
    if (params.smoothing)
        [~, tmp] = spatial_correction ...
            ( its, 'borderMethod', 'none', ...
            'spatialMethod', 'localplanar', varargin{:} );
        its = tmp.spatial;
    end

end