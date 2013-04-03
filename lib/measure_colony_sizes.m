%% Measure Colony Sizes
% Gordon Bean, December 2012
%
% Measures the sizes of colonies in the image.
% First argument may be the image data or a file name.

function [sizes, grid] = measure_colony_sizes( plate, varargin )

    params = get_params( varargin{:} );
    params = default_param( params, 'manualGrid', false );
    
    params = default_param( params, 'thresholdMethod', local_fitted() );
    params = default_param( params, 'localThreshold', true );
    
    params = default_param( params, 'sizeFunction', ...
        @threshold_bounded );
    
    % Make sure defaults are passed to other functions
    varargin = param_pairs( params );
    
    if (ischar( plate ))
        % plate is file name
        plate = imread(plate);
    end
    
    %% Crop plate
    if (size(plate,3) > 1)
        % Plate is assumed to be in RGB format
        plate = nanmean(plate,3);
        plate = crop_background( plate );
    end
    
    %% Determine grid
    if (params.manualgrid)
        params.grid = manual_grid( plate, varargin{:} );
        if (isempty(params.grid))
            sizes = nan;
            grid = struct;
            return;
        end
    else
        if ( ~isfield( params, 'grid' ) )
            params.grid = determine_colony_grid( plate, varargin{:} );
        end
    end
    
    grid = params.grid;
    
    %% Intensity Thresholds
    if (~isfield(grid, 'thresh'))
        if (params.localthreshold)
            grid.thresh = ...
                compute_local_thresholds(plate, grid, varargin{:});
        else
            grid.thresh = ...
                compute_global_threshold(plate, grid, varargin{:});
        end
    end
    
    %% Iterate over grid positions and measure colonies
    sizes = nan(grid.dims);
    grid.threshed = false(size(plate));
    
    for ii = 1 : prod(grid.dims)
        [sizes(ii), tmp] = params.sizefunction( plate, grid, ii );
        grid.threshed = set_box ...
            (grid.threshed, tmp, grid.r(ii), grid.c(ii));
    end
    grid.params = params;
    
    %% Legacy code...
%     if ischar(params.sizefunction)
%         if (strcmpi(params.sizefunction, 'localfitted'))
%             [sizes, grid.threshed] = local_intensity_fitted_method ...
%                 (plate, grid);
%         end
%     else
%         for rr = 1 : grid.dims(1)
%             for cc = 1 : grid.dims(2)
%                 box = get_box ...
%                     ( plate, grid.r(rr,cc), grid.c(rr,cc), grid.win);
%                 [sizes(rr,cc), b] = params.sizefunction ...
%                     ( box, grid.thresh(rr,cc) );
%                 grid.threshed = set_box ...
%                     ( grid.threshed, b, grid.r(rr,cc), grid.c(rr,cc) );
%             end
%         end
%         if (~any(grid.threshed(:)))
%             pthresh = make_plate_threshold( plate, grid );
%             grid.treshed = plate > pthresh;
%         end
%     end
%     sizes = sizes(:);
    
end