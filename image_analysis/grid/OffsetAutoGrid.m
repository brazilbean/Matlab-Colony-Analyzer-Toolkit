%% Offset Auto Grid - a grid-fitting algorithm
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

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
            % I give it two rounds of fitting to improve accuracy
            ri = (1 : this.midgriddims(1));
            ci = (1 : this.midgriddims(2));

            % Define maximum coordinates for fitting
            rie = find(max(grid.r,[],2)+grid.win < size(plate,1),1,'last');
            cie = find(max(grid.c,[],1)+grid.win < size(plate,2),1,'last');

            % Adjust grid
            grid = adjust_grid( plate, grid, ...
                'rowcoords', 1 : min(ri(end),rie),...
                'colcoords', 1:min(ci(end),cie) );

            % Define maximum coordinates for 2nd round of fitting 
            rie = find(max(grid.r,[],2)+grid.win < size(plate,1),1,'last');
            cie = find(max(grid.c,[],1)+grid.win < size(plate,2),1,'last');

            % Adjust grid 2nd time
            %  make sure the coordinates fit in the plate
            if rie > ri(end)*2 && cie > ci(end)*2
                grid = adjust_grid( plate, grid, ...
                    'rowcoords', 1 : 2 : min(ri(end)*2,rie), ...
                    'colcoords', 1 : 2 : min(ci(end)*2,cie) );
            end
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
            ii = find( ~isnan(grid.r) );
            [ris, cis] = ind2sub( grid.dims, ii );

            % Extrapolate full grid positions based on the known locations
            grid = adjust_grid( plate, grid, ...
                'rowcoords', ris : 2 : grid.dims(1), ...
                'colcoords', cis : 2 : grid.dims(2) );

            % Final adjustment over the full grid
            grid = adjust_grid( plate, grid, 'numMiddleAdjusts', 0 );
        end
    end
end