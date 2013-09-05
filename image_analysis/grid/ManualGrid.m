%% Manual Grid - A tool for placing the grid manually
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

classdef ManualGrid < Closure
    properties
        adjustgrid;
        dimensions;
        gridspacing;
    end
    
    methods
        function this = ManualGrid( varargin )
            this = this@Closure();
            this = default_param( this, ...
                'adjustGrid', true, ...
                'dimensions', nan, ...
                'gridspacing', nan, ...
                varargin{:} );
        end
        
        function grid = fit_grid(this, plate)
            % Initialize grid
            grid = this.initialize_grid(plate);
            
            % Query the user to identify the grid corners
            grid = this.manually_fit_grid(plate, grid);
            
            % Sign the package
            grid.info.GridFunction = this;
            
        end
    
        function grid = closure_method(this, varargin)
            grid = this.fit_grid(varargin{:});
        end
    end
        
    methods( Access = protected )
        function grid = initialize_grid(this, plate)
            % Grid spacing
            if ~isnan(this.gridspacing)
                grid.win = this.gridspacing;
            else
                grid.win = estimate_grid_spacing(plate);
            end

            % Grid dimensions
            if ~isnan(this.dimensions)
                grid.dims = this.dimensions;
            else
                grid.dims = estimate_dimensions( plate, grid.win );
            end

            % Initialize grid row and column coordinates
            [grid.r, grid.c] = deal(nan(grid.dims));
        end
        
        function grid = manually_fit_grid(this, plate, grid)
            success = false;
            while (~success)
                % Get grid corners
                corners = interactive_figure( ...
                    @()this.show_plate(plate), 4, ...
                    'Please select the four corners of the colony grid');

                if isempty(corners) || size(corners,1) < 4
                    grid = [];
                    return;
                end
                grid.info.corners = corners;

                % Determine grid from corners
                grid = determine_grid_from_corners( corners, grid );

                % Adjust grid
                if ( this.adjustgrid )
                    grid = adjust_grid( plate, grid, ...
                        'numMiddleAdjusts', 0 );
                end

                % Verify grid
                fig = figure('position', [2000 0 1000 700]);
                movegui(fig, 'onscreen');
                imagesc(plate)
                colormap gray;
                hold on; scatter( grid.c(:), grid.r(:), '.' ); hold off;
                snapnow;

                resp = questdlg('Is the colony grid accurate?', ...
                    'Verify grid', 'Yes','No','Cancel Analysis','Yes');
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
        end
        
        function h = show_plate(~, plate )
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
end