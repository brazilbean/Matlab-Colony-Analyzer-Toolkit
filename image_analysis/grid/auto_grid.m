%% Auto Grid
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% Automatically determine the colony grid.
%
% Parameters
% ------------------------------------------------------------------------
% midRows <[0.4 0.6]>
%  - the row pixel percentiles defining the middle of the plate.
% midCols <[0.4 0.6]>
%  - the column pixel percentiles defining the middle of the plate.
% midGridDims <[8 8]>
%  - the dimensions of the grid fit to the middle of the plate (used to
%  estimate initial grid orientation and position).
% minSpotSize <10>
%  - the number of pixels required for connected component to be considered
%  a colony.
% gridThresholdMethod <MinFrequency('offset', 5)>
%  - the ThresholdMethod object used to provide an approximate, initial
%  threshold used to determine colony positions.
% sizeStandard <[1853 2765]>
%  - the height and width standard used to estimate the plate orientation.
%  The magnitude of these values is irrelevant - only the ratio is used.
% gridSpacing <estimate_grid_spacing(plate)>
%  - the distance, in pixels, between the centers of adjacent colonies.
% dimensions <estimate_dimensions(plate, grid.win)>
%  - the dimensions of the colony grid (rows x columns)
% 

function grid = auto_grid( plate, varargin )
    params = default_param( varargin, ...
        'midRows', [0.4 0.6], ...
        'midCols', [0.4 0.6], ...
        'midGridDims', [8 8], ...
        'minSpotSize', 10, ...
        'gridThresholdMethod', MinFrequency('offset', 5), ...
        'sizeStandard', [1853 2765]);
    
    %% Grid properties
    % Grid spacing
    if isfield(params, 'gridspacing')
        grid.win = params.gridspacing;
    else
        grid.win = estimate_grid_spacing(plate);
    end
    
    % Grid dimensions
    if isfield(params, 'dimensions')
        grid.dims = params.dimensions;
    else
        grid.dims = estimate_dimensions( plate, grid.win );
    end
    
    % Initialize grid row and column coordinates
    [grid.r, grid.c] = deal(nan(grid.dims));
    
    %% Identify the grid orientation
    % Estimate orienation based on plate and image aspect ratios
    % See the supplemental material for the derivation of this formula
    tang = params.sizestandard(1) / params.sizestandard(2);
    ratiofun = @(xp, yp) atan( -(yp - xp*tang)./(yp*tang-xp) );
    [yp xp] = size(plate);

    theta = ratiofun( xp, yp );
    if ( mean(plate(1,floor(end/2):end)) > mean(plate(1,1:floor(end/2))) )
        theta = -theta;
    end
    
    %% Initial placement of grid
    % Get 2D window of the middle of the plate
    range = @(a) fix(a(1)):fix(a(2));
    mid = plate( range(size(plate,1)*params.midrows), ...
        range(size(plate,2)*params.midcols) );

    % Determine the threshold for identifying colonies
    itmid = params.gridthresholdmethod.determine_threshold(mid);

    % Find colony locations
    stats = regionprops( imclearborder(mid > itmid), 'area', 'centroid' );
    cents = cat(1, stats.Centroid);
    areas = cat(1, stats.Area);
    cents = cents(areas > params.minspotsize,:);
    
    % Find the upper-left colony and determine it's location in the plate
    [~,mi] = min(sqrt(sum(cents.^2,2)));
    r0 = cents(mi,2) + size(plate,1)*params.midrows(1);
    c0 = cents(mi,1) + size(plate,2)*params.midcols(1);

    % Determine the initial grid positions
    [cc0 rr0] = meshgrid((0:params.midgriddims(2)-1)*grid.win, ...
        (0:params.midgriddims(1)-1)*grid.win);

    % Define the initial grid coordinates (top-left corner of grid)
    ri = (1 : size(rr0,1));
    ci = (1 : size(cc0,2));

    % Set positions of initial grid coordinates
    grid.r(ri,ci) = rr0;
    grid.c(ri,ci) = cc0;

    % Rotate grid according to orientation estimate
    rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    val = ~isnan(grid.r);
    tmp = rotmat * [grid.c(val) grid.r(val)]';
    
    % Set updated (rotated) positions
    grid.r(val) = r0 + tmp(2,:);
    grid.c(val) = c0 + tmp(1,:);
    
    %% Adjustment and Extrapolation
    % I give it two rounds of fitting to improve accuracy
    
    % Define maximum coordinates for fitting
    rie = find(max(grid.r,[],2)+grid.win < size(plate,1),1,'last');
    cie = find(max(grid.c,[],1)+grid.win < size(plate,2),1,'last');
    
    % Adjust grid
    grid = adjust_grid( plate, grid, 'rowcoords', 1 : min(ri(end),rie),...
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
    
    %% Determine grid/colony overlap
    % Determine which grid positions have colonies and use this
    % information to determine the grid offset
    eplate = nan(grid.dims);
    if (grid.win == 0)
        error('The grid spacing has been set to 0.');
    end
    
    % Use correlation with a 2D guassian to identify colonies
    gbox = fspecial('gaussian',(2*round(grid.win/2)+1)*[1 1], grid.win/3);
    rmax = find( max(grid.r,[],2) < size(plate,1)-grid.win, 1, 'last' );
    cmax = find( max(grid.c,[],1) < size(plate,2)-grid.win, 1, 'last' );
    
    % Determine colony presence for all positions in the grid
    for rr = 1 : rmax
        for cc = 1 : cmax
            box = get_box(plate, ...
                grid.r(rr,cc), grid.c(rr,cc), grid.win/2);
            eplate(rr,cc) = corr(box(:), gbox(:));
        end
    end

    %% Determine offsets
    % Find the last row and column that are filled with colonies
    correlation_threshold = 0.15;
    roff = find(nanmean(eplate,2) < correlation_threshold, 1)-1;
    if isempty(roff)
        roff = find(nanmean(eplate,2) > correlation_threshold, 1, 'last');
    end
    coff = find(nanmean(eplate,1) < correlation_threshold, 1)-1;
    if isempty(coff)
        coff = find(nanmean(eplate,1) > correlation_threshold, 1, 'last');
    end
    
    % Reassign grid locations according to the coordinate offsets
    tmpr = grid.r;
    tmpc = grid.c;
    grid.r = nan(grid.dims);
    grid.c = nan(grid.dims);

    grid.r(end-roff+1:end,end-coff+1:end) = tmpr(1:roff,1:coff);
    grid.c(end-roff+1:end,end-coff+1:end) = tmpc(1:roff,1:coff);
    
    %% Final adjustments
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





