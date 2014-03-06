%% Offset Auto Grid - a grid-fitting algorithm
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Syntax
% OAG = OffsetAutoGrid();
% OAG = OffsetAutoGrid('Name',Value,...);
% grid = OAG(plate);
% grid = OAG.fit_grid(plate);
% grid = OffsetAutoGrid(...).fit_grid(plate);
%
% Description
% OAG = OffsetAutoGrid() returns an OffsetAutoGrid object with
% the default parameters. This object can be used as a regular object with
% the syntax GRID = OAG.fit_grid(PLATE) (where PLATE is the 2D image
% matrix), or as a function handle with the syntax GRID = OAG(PLATE).
%
% OffsetAutoGrid also accepts name-value arguments from the following
% list (defaults in {}):
%  'dimensions' - a 2-element vector indicating the number of rows and
%  columns in the grid. If not specified, these values are determined using
%  estimate_dimensions.
%
%  'gridSpacing' - a scalar indicating the number of pixels between centers
%  of adjacent colonies. If not specified, this value is determined using
%  estimate_grid_spacing.
%
%  'orientationMethod' {'aspectRatio'} | 'periodic' - indicates which
%  method to use to determine the angle of orientation of the grid (i.e.
%  the angle between the grid alignment and the edge of the image). See
%  AutoGrid for details on these algorithms.
% 
% OffsetAutoGrid accepts additional, advanced parameters as described
% in AutoGrid.
% 
% Algorithm
% The OffsetAutoGrid algorithm follows these steps:
% 1) The grid struct is initialized with the grid spacing
% (estimate_grid_spacing) and grid dimensions (estimate_dimensions).
%
% 2) The initial placement of the grid is determined. This fits the
% top-left portion of the grid to the center of the plate, then
% extrapolates the remaining positions. This results in a grid that extends
% beyond the edges of the plate on the right and lower sides. 
%
% 3) The grid is shifted up and to the left so that all grid positions fall
% within the colony area. The magnitude of the shift is a multiple of the
% grid spacing, so the grid stays aligned with the colonies on the plate.
% The magnitude of the shift is determined by finding the last row and
% column occupied by colonies. This is done by computing the correlation
% between a 2D window at each position and a 2D gaussian surface.
%
% 4) After positioning the grid over the colonies, a final grid adjustment
% is made using adjust_grid.
%
% See also: AutoGrid, estimate_dimensions, estimate_grid_spacing

classdef OffsetAutoGrid < AutoGrid
    methods
        function this = OffsetAutoGrid( varargin )
            this = this@AutoGrid();
            this = default_param( this, ...
                varargin{:} );
        end
        
        function grid = fit_grid(this, plate)
            % Initialize grid (spacing, dimensions, [r,c] = nan)
            grid = this.initialize_grid(plate);
            
            % Identify grid orientation
            grid = this.estimate_grid_orientation(plate, grid);
            
            % Compute initial fit
            grid = this.compute_initial_placement(plate, grid);
            
            % Perform initial adjustment
            grid = this.perform_initial_adjustment(plate, grid);
            
            % Determine grid/colony overlap
            overlap = this.determine_overlap(plate, grid);
            
            % Correct grid offset
            grid = this.correct_offset_grid(grid, overlap);
            
            % Make final adjustments
            grid = this.make_final_adjustments(plate, grid);
            
            % Sign the package
            grid.info.GridFunction = this;
            
        end
        
        function grid = perform_initial_adjustment(this, plate, grid)
            
            % Extrapolate grid
            grid = adjust_grid( plate, grid, ...
                'positions', find(~isnan(grid.r)), ...
                'method', 'polar');
            
            % Fit diagonal of grid
            [cc, rr] = meshgrid(0:grid.dims(2)-1, 0:grid.dims(1)-1);
            foo = round(grid.dims(1)./grid.dims(2) * cc) == rr;
            grid = adjust_grid( plate, grid, ...
                'positions', find(foo,grid.dims(2)), ...
                'method', 'polar');
            
        end
        
        function overlap = determine_overlap(this, plate, grid)
            % Determine which grid positions have colonies and use this
            % information to determine the grid offset
            overlap = nan(grid.dims);
            if (grid.win == 0)
                error('The grid spacing has been set to 0.');
            end

            % Use correlation with a 2D guassian to identify colonies
            gbox = fspecial('gaussian', ...
                (2*round(grid.win/2)+1)*[1 1], grid.win/3);
            rmax = find( ...
                max(grid.r,[],2) < size(plate,1)-grid.win, 1, 'last' );
            cmax = find( ...
                max(grid.c,[],1) < size(plate,2)-grid.win, 1, 'last' );

            % Determine colony presence for all positions in the grid
            for rr = 1 : rmax
                for cc = 1 : cmax
                    box = get_box(plate, ...
                        grid.r(rr,cc), grid.c(rr,cc), grid.win/2);
                    overlap(rr,cc) = corr(box(:), gbox(:));
                end
            end
        end
        
        function grid = correct_offset_grid(this, grid, overlap)
            % Find the last row and column that are filled with colonies
            correlation_threshold = 0.15;
            roff = find(nanmean(overlap,2) < correlation_threshold, 1)-1;
            if isempty(roff)
                roff = find( ...
                    nanmean(overlap,2) > correlation_threshold, 1, 'last');
            end
            coff = find(nanmean(overlap,1) < correlation_threshold, 1)-1;
            if isempty(coff)
                coff = find( ...
                    nanmean(overlap,1) > correlation_threshold, 1, 'last');
            end

            % Reassign grid locations according to the coordinate offsets
            tmpr = grid.r;
            tmpc = grid.c;
            grid.r = nan(grid.dims);
            grid.c = nan(grid.dims);

            grid.r(end-roff+1:end,end-coff+1:end) = tmpr(1:roff,1:coff);
            grid.c(end-roff+1:end,end-coff+1:end) = tmpc(1:roff,1:coff);
        end
        
        function grid = make_final_adjustments(this, plate, grid)
            % Find quadrant of grid with known locations
            ii = find( ~isnan(grid.r), 1 );
            [ris, cis] = ind2sub( grid.dims, ii );

            % Extrapolate full grid positions based on the known locations
            grid = adjust_grid( plate, grid, ...
                'rowcoords', ris : 2 : grid.dims(1), ...
                'colcoords', cis : 2 : grid.dims(2) );

            % Final adjustment over the full grid
            grid = adjust_grid( plate, grid, 'numMiddleAdjusts', 0 );
            grid = adjust_grid( plate, grid, 'numMiddleAdjusts', 0 );
        end
    end
end