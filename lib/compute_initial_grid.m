%% Compute Initial Grid
% Gordon Bean, December 2012

function grid = compute_initial_grid( plate, varargin )
    params = get_params( varargin{:} );
    params = default_param( params, 'sizeStandard', [1853 2765] );
    
    %% Compute grid spacing and dimensions
    params = default_param( params, 'gridSpacing', ...
        estimate_grid_spacing( plate ) );
    win = params.gridspacing;
    
    params = default_param( params, 'dimensions', ...
        estimate_dimensions( plate, win ) );
    dims = params.dimensions;
    
    params = default_param( params, 'threshold', ...
        estimate_intensity_threshold( plate ) );
    it = params.threshold;
    
    grid.win = win;
    grid.thresh = it;
    grid.dims = dims;
    
    %% Identify the grid margins
%     marg = find_margins(plate > it);
%     marg = marg + [win/2 -win/2 win/2 -win/2];
    
%     tmp = [size(plate); fliplr(size(plate))] \ params.sizestandard';
%     x = dims(2) * win;
%     y = dims(1) * win;
%     tmp2 = [ y x; x y ] * tmp;
% 
%     tmp3 = (size(plate) - tmp2')/2;
%     tmp4 = size(plate) - tmp3;
%     marg = [tmp3(1) tmp4(1) tmp3(2) tmp4(2)];

    tang = 1853/2765;
    ratiofun = @(xp, yp) atan( -(yp - xp*tang)./(yp*tang-xp) );
    [yp xp] = size(plate);

    theta = ratiofun( xp, yp );
    if ( mean(plate(1,floor(end/2):end)) > mean(plate(1,1:floor(end/2))) )
        theta = -theta;
    end

    rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    x = dims(2) * win;
    y = dims(1) * win;

    coords = rotmat * [-x/2 -y/2; x/2 -y/2; x/2 y/2; -x/2 y/2]';
    coords = bsxfun(@plus, coords', fliplr(size(plate)/2));   
    
    %% Compute initial grid estimate
    grid = determine_grid_from_corners( coords, grid );
%     [grid.c, grid.r] = meshgrid ...
%         ( linspace( marg(3), marg(4), dims(2) ), ...
%         linspace( marg(1), marg(2), dims(1) ) );
%     
    
end