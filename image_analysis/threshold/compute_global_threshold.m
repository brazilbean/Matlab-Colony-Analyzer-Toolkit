%% Compute Global Threshold
% Gordon Bean, March 2013

function its = compute_global_threshold( plate, grid, varargin )
    params = get_params(varargin{:});
    params = default_param( params, 'thresholdmethod', local_fitted() );
    if (~isobject(params.thresholdmethod) && ...
           ~stcmp(superclasses(params.thresholdmethod),'threshold_method'))
        error(['Method parameter should indicate' ...
            ' a threshold_method subclass']);
    end
    
    % Get global box
    box = plate( round(max(grid.r(1,:))):round(min(grid.r(end,:))), ...
        round(max(grid.c(:,1))):round(min(grid.c(:,end))) );
    
    % Get threshold
    its = zeros(grid.dims) + ...
        params.thresholdmethod.determine_threshold(box);
    
end