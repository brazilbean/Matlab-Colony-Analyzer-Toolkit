%% Determine Colony Grid
% Gordon Bean, December 2012

function grid = determine_colony_grid( plate, varargin )
    params = get_params( varargin{:} );
    
    %% Compute Grid
    if (isfield(params, 'initialGrid'))
        grid = params.initialgrid;
    else
        grid = compute_initial_grid( plate, varargin{:} );
    end

    %% Adjust Grid
    grid = adjust_grid( plate, grid, varargin{:} );
    
end