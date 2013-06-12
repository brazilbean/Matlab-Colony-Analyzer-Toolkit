%% Adjust Grid
% Matlab Colony Analyzer Toolkit
% Gordon Bean, December 2012
%
% Adjust the provided grid to more accurately fit to the underlying image.
%
% Parameters
% ------------------------------------------------------------------------
% adjustmentWindow <round(grid.dims(1)/8)>
%  - the radius of the 2D window of colonies used in the center of the
%  plate to estimate initial grid positioning. 
% fitFunction <@(r,c) [ones(numel(r),1) r(:) c(:)]>
%  - a function handle taking row and column coordinates and returning the
%  matrix used to estimate the linear relationship between grid coordinates
%  and position.
% numMiddleAdjusts <1>
%  - the number of adjustments to perform using the middle of the plate
% numFullAdjusts <1>
%  - the number of adjustments to perform using colonies across the entire
%  plate.
% rowCoords & colCoords
%  - the row and column coordinates of the colonies to use for fitting the
%  grid to the image.
%

function grid = adjust_grid( plate, grid, varargin )
    params = default_param( varargin, ...
        'adjustmentWindow', round(grid.dims(1)/8), ...
        'fitfunction', @(r,c) [ones(numel(r),1) r(:) c(:)], ...
        'numMiddleAdjusts', 1, ...
        'numFullAdjusts', 1 );
    aw = params.adjustmentwindow;
    
    %% Pre-defined coordinates or default coordinates?
    if isfield(params, 'rowcoords') && isfield(params, 'colcoords')
        % Use pre-defined coordinates for fitting
        grid = minor_adjust_grid( plate, grid, ...
            params.rowcoords, params.colcoords );
        
    else
        % Use default coordinates for fitting
        
        %% Middle adjustment
        % First, adjust using coordinates from the middle of the plate
        for iter = 1 : params.nummiddleadjusts
            %% Adjust internal spots

            rrr = grid.dims(1)/2 - aw : grid.dims(1)/2 + aw + 1;
            ccc = grid.dims(2)/2 - aw : grid.dims(2)/2 + aw + 1;

            grid = minor_adjust_grid( plate, grid, rrr, ccc );

        end

        %% Plate-wide adjustment
        % Use coordinates across the full grid
        for iter = 1 : params.numfulladjusts
            rrr = round( linspace( 1, grid.dims(1), 2*aw ) );
            ccc = round( linspace( 1, grid.dims(2), 2*aw ) );

            grid = minor_adjust_grid( plate, grid, rrr, ccc );
        end
    end
    
    %% Add meta-data
    % Update the grid spacing
    grid.win = round(median(diff(grid.c( grid.dims(1)/2, :))));
    
    % Update the grid orientation
    grid.info.theta = pi/2 - atan2 ...
        ( grid.factors.row(2), grid.factors.row(3) );
    
    % Include the funciton used for fitting the grid
    grid.info.fitfunction = params.fitfunction;
    
    %% ---- Subroutines ---- %%
    
    %% Minor Adjust Grid
    % For each defined position, compute the true colony location
    % Compute the fit between the coordinates and locations
    % Extrapolate remaining colony locations
    function grid = minor_adjust_grid( plate, grid, rrr, ccc )
    
        % Setup
        dims = grid.dims;
        win = grid.win;
        
        [rtmp ctmp] = deal( nan(size(grid.r)) );

        %% Find true colony locations
        for rr = rrr(:)'
            for cc = ccc(:)'
                [rtmp(rr,cc) ctmp(rr,cc) ] = adjust_spot ...
                    (plate, grid.r(rr,cc), grid.c(rr,cc), win);
            end
        end

        %% Estimate grid parameters
        iii = in(~isnan(rtmp) & ~isnan(ctmp));
        [cc, rr] = meshgrid( 1 : dims(2), 1 : dims(1) );
        Afun = params.fitfunction;
        
        rfact = Afun(rr(iii),cc(iii)) \ rtmp(iii);
        cfact = Afun(rr(iii),cc(iii)) \ ctmp(iii);

        grid.factors.row = rfact;
        grid.factors.col = cfact;
    
        %% Compute grid position
        grid.r = reshape(Afun(rr(:),cc(:)) * rfact, size(grid.r));
        grid.c = reshape(Afun(rr(:),cc(:)) * cfact, size(grid.r));
        
    end
    
    %% Adjust spot
    % Determine the true location of the given colony
    function [rpos cpos] = adjust_spot( plate, rpos, cpos, win )
        
        % Get the 2D window around the colony
        box = get_box( plate, rpos, cpos, win );
        
        % Measure the offset
        off = measure_colony_offset( box );
        
        % Check for error cases
        if (any(off > win/2))
            error('Offset too large - %s', ...
                'the adjustment window may need to be smaller.');
        end
        
        % Return adjusted location
        if (isnan(off))
            % Colony is empty or other error occurred measuring the offset
            rpos = nan;
            cpos = nan;
        
        else
            % Return the original location plus the offset
            rpos = rpos + off(1);
            cpos = cpos + off(2);
        end        
    end

end