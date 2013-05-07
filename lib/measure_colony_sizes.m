%% Measure Colony Sizes
% Gordon Bean, December 2012
%
% Measures the sizes of colonies in the image.
% First argument may be the image data or a file name.

function [sizes, grid] = measure_colony_sizes( plate, varargin )

    params = default_param( varargin, ...
        'manualGrid', false, ...
        'thresholdMethod', local_fitted(), ... 
        'sizeFunction', @threshold_bounded );
    
    % Make sure defaults are passed to other functions
    varargin = param_pairs( params );
    
    %% Load Plate
    if (ischar( plate ))
        % plate is file name
        plate = load_plate(plate, varargin{:});
    end
    
    %% Crop plate
    if (size(plate,3) > 1)
        % Plate is assumed to be in RGB format
        plate = nanmean(plate,3);
        plate = crop_background( plate );
    end

    %% Determine grid
    if (params.manualgrid)
        % Manual Grid
        params.grid = manual_grid( plate, varargin{:} );
        if (isempty(params.grid))
            sizes = nan;
            grid = struct;
            return;
        end
        
    else
        % Auto Grid
        if ( ~isfield( params, 'grid' ) )
            params.grid = determine_colony_grid( plate, varargin{:} );
        end
    end
    
    grid = params.grid;
    
    %% Intensity Thresholds
    if (~isfield(grid, 'thresh'))
        grid.thresh = params.thresholdmethod.apply_threshold(plate, grid);
    end
    
    %% Iterate over grid positions and measure colonies
    sizes = nan(grid.dims);
    grid.threshed = false(size(plate));
    
    for ii = 1 : prod(grid.dims)
        sizes(ii) = params.sizefunction( plate, grid, ii );
    end
    grid.params = params;
    
end