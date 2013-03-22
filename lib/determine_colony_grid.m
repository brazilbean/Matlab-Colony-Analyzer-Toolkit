%% Determine Colony Grid
% Gordon Bean, December 2012

function grid = determine_colony_grid( plate, varargin )
    params = get_params( varargin{:} );
    
    %% Compute Grid
    params = default_param ...
        ( params, 'grid', compute_initial_grid( plate, varargin{:} ));

    grid = params.grid;
    
    %% Adjust Grid
    grid = adjust_grid( plate, grid, varargin{:} );
    
end