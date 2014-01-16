%% Iterative Offset Grid - a grid-fitting algorithm
% Matlab Colony Analyzer Toolkit
% Gordon Bean, January 2014

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
            
            % Iterate on the columns
            grid = this.adjust_columns(plate, grid, refbox);
            
        end
        
        function grid = adjust_rows(this, plate, grid, refbox)
            next_row = nan(grid.dims(2),2);
            w = fix((size(refbox,1)-1)/2);
            for ii = 1 : grid.dims(2)
                try
                    tmpbox = get_box ...
                        (plate, grid.r(1,ii)-grid.win, grid.c(1,ii), w);
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
                grid.r(1,:) = grid.r(2,:)-grid.win;
                grid = this.adjust_rows(plate, grid, refbox);
            end
        end
        
        function grid = adjust_columns(this, plate, grid, refbox)
            next_col = nan(grid.dims(1),2);
            w = fix((size(refbox,1)-1)/2);
            for ii = 1 : grid.dims(1)
                try
                    tmpbox = get_box ...
                        (plate, grid.r(ii,1), grid.c(ii,1)-grid.win, w);
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
                grid.c(:,1) = grid.c(:,2)-grid.win;
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