%% Iterative Offset Grid - a grid-fitting algorithm
% Matlab Colony Analyzer Toolkit
% Gordon Bean, January 2014
%
% Syntax
% IOG = IterativeOffsetGrid();
% IOG = IterativeOffsetGrid('Name',Value,...);
% grid = IOG(plate);
% grid = IOG.fit_grid(plate);
% grid = IterativeOffsetGrid(...).fit_grid(plate);
%
% Description
% IOG = IterativeOffsetGrid() returns an IterativeOffsetGrid object with
% the default parameters. This object can be used as a regular object with
% the syntax GRID = IOG.fit_grid(PLATE) (where PLATE is the 2D image
% matrix), or as a function handle with the syntax GRID = IOG(PLATE).
%
% IterativeOffsetGrid also accepts name-value arguments from the following
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
% IterativeOffsetGrid accepts additional, advanced parameters as described
% in AutoGrid.
% 
% Algorithm
% The IterativeOffsetGrid algorithm follows these steps:
% 1) The grid struct is initialized with the grid spacing
% (estimate_grid_spacing) and grid dimensions (estimate_dimensions).
%
% 2) The initial placement of the grid is determined. This fits the
% top-left portion of the grid to the center of the plate, then
% extrapolates the remaining positions. This results in a grid that extends
% beyond the edges of the plate on the right and lower sides. 
%
% 3) The grid is shifted up and to the left so that all grid positions fall
% within the image matrix. The magnitude of the shift is a multiple of the
% grid spacing, so the grid stays aligned with the colonies on the plate.
%
% 4) The grid is iteratively shifted by one row or column at a time until
% the grid is aligned to the colonies. This is done by comparing the
% space in the adjacent row/column to the space in the final row/column. If
% the adjacent space better matches a profile of colonies than the final
% row/column, the grid is shifted. Note that if the grid is positioned such
% that it does not include the top row, then the bottom row of the grid
% will extend beyond the colonies and cover background; thus, by comparing
% these two rows, the correct position can be determined. 
%
% 5) After positioning the grid over the colonies, a final grid adjustment
% is made using adjust_grid.
%
% See also: AutoGrid, estimate_dimensions, estimate_grid_spacing

classdef IterativeOffsetGrid < AutoGrid
    methods
        function this = IterativeOffsetGrid( varargin )
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
            
            % Correct grid offset
            grid = this.correct_offset_grid(plate, grid);
            
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
        
        function grid = correct_offset_grid(this, plate, grid)
            % Define the reference position
            win = grid.win * 0.5;;
            refbox = mean(cat(3, ...
                get_box(plate, grid.r(1,1), grid.c(1,1), win), ...
                get_box(plate, grid.r(1,2), grid.c(1,2), win), ...
                get_box(plate, grid.r(2,1), grid.c(2,1), win), ...
                get_box(plate, grid.r(2,2), grid.c(2,2), win)),3);

            % Correct the out-of-image positions
            out_of_range = ...
                grid.r+grid.win > size(plate,1) | grid.r-grid.win < 1 ...
                | grid.c+grid.win > size(plate,2) | grid.c-grid.win < 1;
            
            r_off = find(all(out_of_range,2),1) - 1;
            c_off = find(all(out_of_range,1),1) - 1;
            
            tmpr = grid.r;
            tmpc = grid.c;
            grid.r = nan(grid.dims);
            grid.c = nan(grid.dims);

            grid.r(end-r_off+1:end,end-c_off+1:end) = ...
                tmpr(1:r_off,1:c_off);
            grid.c(end-r_off+1:end,end-c_off+1:end) = ...
                tmpc(1:r_off,1:c_off);

            ii = find( ~isnan(grid.r), 1 );
            [ris, cis] = ind2sub( grid.dims, ii );

            grid = adjust_grid( plate, grid, ...
                    'rowcoords', ris : 2 : grid.dims(1), ...
                    'colcoords', cis : 2 : grid.dims(2) );

            % Iterate on the rows
            grid = this.adjust_rows(plate, grid, refbox);
            grid = adjust_grid( plate, grid, ...
                    'rowcoords', 1 : 2 : grid.dims(1), ...
                    'colcoords', 1 : 2 : grid.dims(2) );
                
            % Iterate on the columns
            grid = this.adjust_columns(plate, grid, refbox);
            
        end
        
        function grid = adjust_rows(this, plate, grid, refbox)
            next_row = nan(grid.dims(2),2);
            w = fix((size(refbox,1)-1)/2);
            fact = grid.info.factors.col;
            for ii = 1 : grid.dims(2)
                try
                    tmpbox = get_box(plate, ...
                        grid.r(1,ii)-fact(3), grid.c(1,ii)-fact(2), w);
                catch e
                    tmpbox = nan(size(refbox));
                end
                next_row(ii,1) = corr(refbox(:), tmpbox(:));

                try
                    tmpbox = get_box ...
                        (plate, grid.r(end,ii), grid.c(end,ii), w);
                catch e
                    tmpbox = nan(size(refbox));
                end
                next_row(ii,2) = corr(refbox(:), tmpbox(:));

            end

            % If the next row is better, move, then repeat.
            if nanmean(next_row(:,1)) > nanmean(next_row(:,2))
                tmpr = grid.r;
                grid.r(2:end,:) = tmpr(1:end-1,:);
                grid.r(1,:) = grid.r(2,:)-fact(3);
                grid.c(1,:) = grid.c(2,:)-fact(2);
                grid = this.adjust_rows(plate, grid, refbox);
            end
        end
        
        function grid = adjust_columns(this, plate, grid, refbox)
            next_col = nan(grid.dims(1),2);
            w = fix((size(refbox,1)-1)/2);
            fact = grid.info.factors.row;
            for ii = 1 : grid.dims(1)
                try
                    tmpbox = get_box(plate, ...
                        grid.r(ii,1)-fact(3), grid.c(ii,1)-fact(2), w);
                catch e
                    tmpbox = nan(size(refbox));
                end
                next_col(ii,1) = corr(refbox(:), tmpbox(:));

                try
                    tmpbox = get_box ...
                        (plate, grid.r(ii,end), grid.c(ii,end), w);
                catch e
                    tmpbox = nan(size(refbox));
                end
                next_col(ii,2) = corr(refbox(:), tmpbox(:));

            end

            % If the next row is better, move, then repeat.
            if nanmean(next_col(:,1)) > nanmean(next_col(:,2))
                tmpc = grid.c;
                grid.c(:,2:end) = tmpc(:,1:end-1);
                grid.c(:,1) = grid.c(:,2)-fact(2);
                grid.r(:,1) = grid.r(:,2)-fact(3);
                grid = this.adjust_columns(plate, grid, refbox);
            end
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