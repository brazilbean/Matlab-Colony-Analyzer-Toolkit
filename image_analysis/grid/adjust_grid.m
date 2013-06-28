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
        'method', 'linear', ...
        'adjustmentWindow', round(grid.dims(1)/8), ...
        'fitfunction', @(r,c) [ones(numel(r),1) r(:) c(:)], ...
        'numMiddleAdjusts', 1, ...
        'numFullAdjusts', 1 );
    aw = params.adjustmentwindow;
    
    methods.linear = @minor_adjust_grid;
    methods.polar = @polar_adjust_grid;
    
    %% Pre-defined coordinates or default coordinates?
    if (isfield(params, 'rowcoords') && isfield(params, 'colcoords')) ...
            || isfield(params, 'positions')
        % Use pre-defined coordinates for fitting
        
        if ~isfield(params, 'positions')
            [cfoo, rfoo] = meshgrid(params.colcoords, params.rowcoords);
            params.positions = sub2ind(grid.dims, rfoo, cfoo);
        end
        grid = methods.(lower(params.method))...
            ( plate, grid, params.positions );
        
    else
        % Use default coordinates for fitting
        
        %% Middle adjustment
        % First, adjust using coordinates from the middle of the plate
        for iter = 1 : params.nummiddleadjusts
            %% Adjust internal spots

            rrr = grid.dims(1)/2 - aw : grid.dims(1)/2 + aw + 1;
            ccc = grid.dims(2)/2 - aw : grid.dims(2)/2 + aw + 1;
            [cfoo, rfoo] = meshgrid(ccc, rrr);
            inds = sub2ind(grid.dims, rfoo, cfoo);

            grid = methods.(lower(params.method))...
                ( plate, grid, inds );

        end

        %% Plate-wide adjustment
        % Use coordinates across the full grid
        for iter = 1 : params.numfulladjusts
            rrr = round( linspace( 1, grid.dims(1), 2*aw ) );
            ccc = round( linspace( 1, grid.dims(2), 2*aw ) );
            [cfoo, rfoo] = meshgrid(ccc, rrr);
            inds = sub2ind(grid.dims, rfoo, cfoo);

            grid = methods.(lower(params.method))...
                ( plate, grid, inds );
        
        end
    end
    
    %% Add meta-data
    % Update the grid spacing
    grid.win = round(median(diff(grid.c( grid.dims(1)/2, :))));
    
    % Include the funciton used for fitting the grid
    grid.info.fitfunction = params.fitfunction;
    
    %% ---- Subroutines ---- %%
    
    %% Polar Adjust Grid
    function grid = polar_adjust_grid( plate, grid, inds )
        % Setup
        win = grid.win;
        
        [rtmp ctmp] = deal( nan(size(grid.r)) );

        %% Find true colony locations
        for ii = inds(:)'
            [rtmp(ii), ctmp(ii)] = adjust_spot ...
                ( plate, grid.r(ii), grid.c(ii), win);
        end
        if all(isnan(rtmp(:))) || all(isnan(ctmp(:)))
            error('Grid adjustment resulted in NaN grid.');
        end
        
        %% Conver to polar
        % Set reference as top-left coordinate
        ii = find(~isnan(rtmp),1);
        [r0, c0] = deal(rtmp(ii), ctmp(ii));

        % Set top-left as reference
        rpos = rtmp - r0;
        cpos = ctmp - c0;

        % Compute rho (radius)
        rho = sqrt(rpos.^2 + cpos.^2);

        % Compute theta
        theta = atan2(-rpos, cpos); 
         % -rpos because rows are counted down
        
        %% Compute expected positions (in polar)
        [cc, rr] = meshgrid(1:grid.dims(2), 1:grid.dims(1));
        [r0i, c0i] = ind2sub(grid.dims, ii);
        rr = rr - r0i;
        cc = cc - c0i;
        
        rho_exp = sqrt(rr.^2 + cc.^2);
        theta_exp = atan2(-rr, cc);

        % Update theta
        theta_fact = nanmedian(theta(:) - theta_exp(:));

        % Update rho
        rho_fact = nanmedian(rho(:) ./ rho_exp(:));

        %% Return cartesian, updated coordinates
        grid.r = ...
            -rho_fact * rho_exp .* sin(theta_exp + theta_fact) + r0;
        grid.c = ...
            rho_fact * rho_exp .* cos(theta_exp + theta_fact) + c0;
        
        grid.info.theta = theta_fact;
        
        if all(isnan(grid.r(:))) || all(isnan(grid.c(:)))
            error('Grid adjustment resulted in NaN grid.');
        end
        
    end

    %% Minor Adjust Grid
    % For each defined position, compute the true colony location
    % Compute the fit between the coordinates and locations
    % Extrapolate remaining colony locations
    function grid = minor_adjust_grid( plate, grid, inds )
    
        % Setup
        dims = grid.dims;
        win = grid.win;
        
        [rtmp ctmp] = deal( nan(size(grid.r)) );

        %% Find true colony locations
        for ii = inds(:)'
            [rtmp(ii), ctmp(ii)] = adjust_spot ...
                ( plate, grid.r(ii), grid.c(ii), win);
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
        
        % Update the grid orientation
        grid.info.theta = pi/2 - atan2 ...
            ( grid.factors.row(2), grid.factors.row(3) );
    
    end
    
    %% Adjust spot
    % Determine the true location of the given colony
    function [rpos cpos] = adjust_spot( plate, rpos, cpos, win )
        if (rpos + win > size(plate,1) || cpos + win > size(plate,2) ...
                || rpos - win < 1 || cpos - win < 1 ...
                || isnan(rpos) || isnan(cpos))
            rpos = nan;
            cpos = nan;
            return
        end
        
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