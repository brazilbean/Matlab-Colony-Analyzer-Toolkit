%% Auto Grid - An auto-grid algorithm based on an optimal fit
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Syntax
% AG = AutoGrid();
% AG = AutoGrid('Name',Value,...);
% grid = AG(plate);
% grid = AG.fit_grid(plate);
% grid = AutoGrid(...).fit_grid(plate);
%
% Description
% AG = AutoGrid() returns an IterativeOffsetGrid object with
% the default parameters. This object can be used as a regular object with
% the syntax GRID = AG.fit_grid(PLATE) (where PLATE is the 2D image
% matrix), or as a function handle with the syntax GRID = AG(PLATE).
%
% AutoGrid also accepts name-value arguments from the following
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
%  the angle between the grid alignment and the edge of the image). 
%  See Algorithms.
%
%  'offsetStep' {3} - a scalar indicating the step size in the global
%  fitting step. See Algorithms.
%
% AutoGrid accepts addition, advanced parameters, including:
%  'midRows' {[0.4 0.6]} - a 2-element vector indicating the percentile
%  range of pixel rows defining the center of the colony region.
%
%  'midCols' {[0.4 0.6]} - a 2-element vector indicating the percentile
%  range of pixel columns defining the center of the colony region.
%
%  'midGridDims' {[8 8]} - a 2-element vector indicating the dimensions
%  (rows x columns) of the sub-grid to fit to the center of the colony
%  region. See Algorithms below.
% 
%  'minSpotSize' {10} - a scalar indicating the minimum size, in number of
%  pixels, for a colony to be including the the initial fitting process.
% 
%  'gridThresholdMethod' {MaxMinMean()} - a Threshold object used to
%  determine colonies for the initial fitting process.
%
%  'sizeStandard' {[1853 2765]} - a 2-element vector indicating the
%  relative proportions of the height and width of a cropped image. Used
%  only when 'orientationMethod' is set to 'aspectRatio'.
%
% Algorithms
% Orientation method
% There are two algorithms for determining the orientation of the plate
% (i.e. the angle between the edge of the plate and the edge of the image).
%  'aspectRatio' uses the ratio of the height and width of the plate, the
% same ratio of the cropped image, and basic trigonometry to determine the
% angle of orientation of the plate. This algorithm assumes the image has
% been cropped to the outside of the plate (such as with crop_background -
% see PlateLoader).
%  'periodic' - see estimate_orientation. This algorithm does not require
% specific cropping.
% 
% Fitting the grid
% AutoGrid uses a brute-force searching method to determine the grid
% position. After estimating the grid spacing and dimensions, it creates
% the respective grid and then computes the fit of that grid over all valid
% positions (i.e. the grid is entirely contained in the image). The search
% space can be reduced with the parameter 'offsetStep', which indicates the
% distance between evaluated positions. 
% 
% 
classdef AutoGrid < Closure
   
    properties
        midrows;
        midcols;
        midgriddims;
        minspotsize;
        gridthresholdmethod;
        offsetstep;
        sizestandard;
        
        dimensions;
        gridspacing;
        orientationmethod;
    end
    
    methods
        
        function this = AutoGrid( varargin )
            this = this@Closure();
            this = default_param( this, ...
                'midRows', [0.4 0.6], ...
                'midCols', [0.4 0.6], ...
                'midGridDims', [8 8], ...
                'minSpotSize', 10, ...
                ...'gridThresholdMethod', MinFrequency('offset', 5), ...
                ...'gridThresholdMethod', MaxMinMean(), ...
                'gridThresholdMethod', @disjoint_component_threshold, ...
                'offsetStep', 3, ...
                'sizeStandard', [1853 2765], ...
                'dimensions', nan, ...
                'gridspacing', nan, ...
                'orientationMethod', 'aspectRatio', ... 'periodic'
                varargin{:} ); 
        end
        
        function grid = closure_method(this, varargin)
            grid = this.fit_grid(varargin{:});
        end
        
        function grid = fit_grid(this, plate)
            % Initialize grid (spacing, dimensions, [r,c] = nan)
            grid = this.initialize_grid(plate);
            
            % Identify grid orientation
            grid = this.estimate_grid_orientation(plate, grid);
            
            % Compute initial placement
            grid = this.compute_initial_placement(plate, grid);
            
            % Compute the linear parameters of the grid
            grid = this.compute_linear_parameters(plate, grid);
            
            % Search for optimal placement
            grid = this.find_optimal_placement(plate, grid);
            
            % Final adjustment
%             grid = adjust_grid( plate, grid, 'numMiddleAdjusts', 0 );
            grid = adjust_grid( plate, grid );
            
            % Sign the package
            grid.info.GridFunction = this;
        end
        
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
        
        function grid = estimate_grid_orientation(this, plate, grid)
            switch lower(this.orientationmethod)
                case 'aspectratio'
                    tang = this.sizestandard(1) / this.sizestandard(2);
                    ratiofun = ...
                        @(xp, yp) atan( -(yp - xp*tang)./(yp*tang-xp) );
                    [yp, xp] = size(plate);

                    theta = ratiofun( xp, yp );
                    if ( mean(plate(1,floor(end/2):end)) > ...
                            mean(plate(1,1:floor(end/2))) )
                        theta = -theta;
                    end
                    grid.info.theta = theta;
                    
                case 'periodic'
                    grid.info.theta = estimate_orientation(plate, nan, ...
                        'gridSpacing', grid.win, 'filter', @(x) x < 5);
                    
                otherwise
                    error('Invalid orientation method: %s', ...
                        this.orientationmethod);
            end
        end
        
        function grid = compute_initial_placement(this, plate, grid)
            % Get 2D window of the middle of the plate
            range = @(a) fix(a(1)):fix(a(2));
            mid = plate( range(size(plate,1)*this.midrows), ...
                range(size(plate,2)*this.midcols) );

            % Determine the threshold for identifying colonies
            itmid = this.gridthresholdmethod(mid);
            if numel(itmid) == 1
                % threshold method returned a threshold value
                bmid = mid > itmid;
            else
                % threshold method returned a binary image
                bmid = itmid;
            end

            % Find colony locations
            [inds, labs] = label_components( bmid );
            [cents, areas] = component_props( bmid, inds );
            
            % Ignore colonies on the border or that are too small
            lab_nix = unique([labs([1 end],:) labs(:,[1 end])']);
            lab_nix = in(lab_nix, @(x) x ~= 0);
            lab_keep = fil(true(size(areas)), lab_nix, false);
            cents = cents(lab_keep & areas > this.minspotsize,:);

            % Find the upper-left colony and determine 
            %  it's location in the plate
            [~,mi] = min(sqrt(sum(cents.^2,2)));
            r0 = cents(mi,2) + size(plate,1)*this.midrows(1);
            c0 = cents(mi,1) + size(plate,2)*this.midcols(1);

            % Determine the initial grid positions
            [cc0, rr0] = meshgrid((0:this.midgriddims(2)-1)*grid.win, ...
                (0:this.midgriddims(1)-1)*grid.win);

            % Define the initial grid coordinates (top-left corner of grid)
            ri = (1 : size(rr0,1));
            ci = (1 : size(cc0,2));

            % Set positions of initial grid coordinates
            grid.r(ri,ci) = rr0;
            grid.c(ri,ci) = cc0;

            % Rotate grid according to orientation estimate
            theta = grid.info.theta;
            rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
            val = ~isnan(grid.r);
            tmp = rotmat * [grid.c(val) grid.r(val)]';

            % Set updated (rotated) positions
            grid.r(val) = r0 + tmp(2,:);
            grid.c(val) = c0 + tmp(1,:);
        end
        
        function grid = compute_linear_parameters(this, plate, grid)
            % Adjust - get linear factors
            ri = (1 : this.midgriddims(1));
            ci = (1 : this.midgriddims(2));

            % Define maximum coordinates for fitting
            rie = find(max(grid.r,[],2)+grid.win < size(plate,1),1,'last');
            cie = find(max(grid.c,[],1)+grid.win < size(plate,2),1,'last');

            % Adjust grid
            grid = adjust_grid( plate, grid, ...
                'rowcoords', 1 : min(ri(end),rie),...
                'colcoords', 1:min(ci(end),cie) );
        end
        
        function grid = find_optimal_placement(this, plate, grid)
            % Compute linear indices of grid
            [cc,rr] = meshgrid(1:grid.dims(2), 1:grid.dims(1));
            rtmp = grid.info.fitfunction(rr(:),cc(:)) * ...
                ([0 1 1]' .* grid.info.factors.row);
            ctmp = grid.info.fitfunction(rr(:),cc(:)) * ...
                ([0 1 1]' .* grid.info.factors.col);

            rtmp = round(rtmp);
            rtmp = rtmp - min(rtmp(:)) + 1;
            ctmp = round(ctmp);
            ctmp = ctmp - min(ctmp(:)) + 1;
            
            % Get just the border positions
            mid = true(grid.dims);
            mid(3:end-2,3:end-2) = false;
            mid = mid(:);
            gi = sub2ind(size(plate), round(rtmp(mid)), round(ctmp(mid)));

            % Compute offset grid
            roff = 1 : this.offsetstep : ...
                floor(size(plate,1)-ceil(max(rtmp(:))));
            roff = roff - 1;
            
            coff_ = 1 : this.offsetstep : ...
                floor(size(plate,2)-ceil(max(ctmp(:))));
            coff_ = coff_ - 1;
            coff = coff_ * size(plate,1);

            tmpoff = bsxfun(@plus, roff', coff);
            allpos = bsxfun(@plus, tmpoff, permute(gi, [2 3 1]));

            % Find optimal placement
            tmp_plate = plate(:);
            allplate = tmp_plate(allpos);
            clear tmp_plate

            [row,col] = ind2sub(size(tmpoff),argmax(in(mean(allplate,3))));

            grid.r(:) = rtmp(:) + roff(row);
            grid.c(:) = ctmp(:) + coff_(col);
%             [rpos, cpos] = ind2sub(size(plate), allpos(row, col,:));
%             grid.r(:) = rpos(:);
%             grid.c(:) = cpos(:);
        end
    end
    
end



