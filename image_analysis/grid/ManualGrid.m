%% Manual Grid - A tool for placing the colony grid manually
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Syntax
% Using ManualGrid as a parameterizeable function:
% MG = ManualGrid()
% MG = ManualGrid( 'Name', Value, ... )
% grid = MG( plate )
%
% Using ManualGrid as a regular object.
% grid = ManualGrid(...).fit_grid( plate )
%
% Description
% ManualGrid is a class object that defines a tool for manually specifying
% the position of the colony grid on an image. It can be used as a
% parameterizeable function - i.e. you treat the object returned by the
% constructor as a function handle - or as a regular object, which you use
% to call fit_grid().
%
% MG = ManualGrid() returns a callable object (similar in usage to a
% function handle) with the default parameters.
%
% MG = ManualGrid( 'Name', Value, ... ) accepts name-value pairs from the
% following list (defaults in {}):
%  'adjustGrid' {true} - if false, proposed coordinates for the corners of
%  the grid are take as-is and no attempt is made to fit the interpolated
%  grid to the image (using adjust_grid). 
%
%  'dimensions' - a 2-element vector indicating the number of rows and
%  columns in the grid. If this parameter is not provided, ManualGrid will
%  attempt to estimate the dimensions using the grid spacing using
%  estimate_dimensions.
%
%  'gridSpacing' - a scalar indicating the distance in pixels between the
%  centers of adjacent colonies. If this parameter is not provided,
%  ManualGrid attempts to estimate the grid spacing using
%  estimate_grid_spacing.
%
%  'numberCorners' {true} - if false, the corners are not numbered when the
%  user is queried for the positions of the grid corners. Because of the UI
%  callback mechanism, the numbering may interfer with coordinate selection
%  when the image is cropped very closely to the colonies; in such cases,
%  set 'numberCorners' to false (be aware the order in which corners are
%  selected still matters).
%
% Note: It is often the case that if the ManualGrid tool is required,
% estimate_grid_spacing will likely fail. To ensure success, I suggest
% always defining the 'dimensions' parameter when using ManualGrid.
%
% After calling the constructor, the returned object may be used like a
% function handle (see examples below).
%
% Examples
% Using ManualGrid as a parameterizeable function:
% MG = ManualGrid('dimensions', [64 96]);
% grid = MG( plate );
%
% Using ManualGrid as a regular object:
% MG = ManualGrid('dimensions', [64 96]);
% grid = MG.fit_grid( plate );
%
% grid = ManualGrid('dimensions', [64 96]).fit_grid(plate);
%
% See also tutorials/grid_alignment_tutorial.m

classdef ManualGrid < Closure
    properties
        adjustgrid;
        dimensions;
        gridspacing;
        numbercorners;
    end
    
    methods
        function this = ManualGrid( varargin )
            this = this@Closure();
            this = default_param( this, ...
                'adjustGrid', true, ...
                'dimensions', nan, ...
                'gridspacing', nan, ...
                'numberCorners', true, ...
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
            % Grid dimensions
            if ~isnan(this.dimensions)
                grid.dims = this.dimensions;
                
            else
                % Grid spacing
                if ~isnan(this.gridspacing)
                    grid.win = this.gridspacing;
                else
                    grid.win = estimate_grid_spacing(plate);
                end

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
        
        function h = show_plate(this, plate )
            h = imagesc( plate );
            colormap gray;

            if this.numbercorners
                sz = size(plate);
                w = 100;
                text(w, w, '1', 'color', 'red', 'fontsize', 24 );
                text(sz(2)-w, w, '2', 'color', 'red', 'fontsize', 24 );
                text(w, sz(1)-w, '4', 'color', 'red', 'fontsize', 24 );
                text(sz(2)-w, sz(1)-w, '3', 'color', 'red', ...
                    'fontsize', 24 );
            end

        end
    end
end