%% Manual Grid
% Gordon Bean, December 2012

function grid = manual_grid( plate, varargin )

    params = get_params( varargin{:} );
    params = default_param( params, 'adjustGrid', true );
    
    %% Determine grid spacing, etc.
    params = default_param( params, 'gridSpacing', ...
        estimate_grid_spacing( plate ) );
    grid.win = params.gridspacing;
    
    if (~isfield( params, 'dimensions' ))
        grid.dims = estimate_dimensions( plate, grid.win );
    else
        grid.dims = params.dimensions;
    end
    
    success = false;
    while (~success)
        %% Get grid corners
        corners = interactive_figure( @()show_plate(plate), 4, ...
            'Please select the four corners of the colony grid');

        if (isnan(corners))
            grid = [];
            return;
        end
        grid.info.corners = corners;

        %% Determine initial grid
        grid = determine_grid_from_corners( corners, grid );
        
        %% Adjust grid
        if ( params.adjustgrid )
            grid = adjust_grid( plate, grid, ...
                'numMiddleAdjusts', 0, varargin{:} );
        end

        %% Verify grid
        fig = figure('position', [2000 0 1000 700]);
        movegui(fig, 'onscreen');
        imagesc(plate)
        colormap gray;
        hold on; scatter( grid.c(:), grid.r(:), '.' ); hold off;
        snapnow;

        resp = questdlg('Is the colony grid accurate?', 'Verify grid', ...
            'Yes','No','Cancel Analysis','Yes');
        close(fig);
        snapnow;
        
        switch resp
            case 'Yes'
                success = true;

            case 'No'
                success = false;

            case 'Cancel Analysis'
                grid = [];
                return;
        end
        
        
    end
    
    %% ---- Subroutines ---- %%
    function h = show_plate( plate )
        h = imagesc( plate );
        colormap gray;
        
        sz = size(plate);
        w = 100;
        text(w, w, '1', 'color', 'red', 'fontsize', 24 );
        text(sz(2)-w, w, '2', 'color', 'red', 'fontsize', 24 );
        text(w, sz(1)-w, '4', 'color', 'red', 'fontsize', 24 );
        text(sz(2)-w, sz(1)-w, '3', 'color', 'red', 'fontsize', 24 );
        
    end

end