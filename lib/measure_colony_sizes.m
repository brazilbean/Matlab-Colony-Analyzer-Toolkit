%% Measure Colony Sizes
% Gordon Bean, December 2012
%
% Measures the sizes of colonies in the image.
% First argument may be the image data or a file name.

function [sizes, grid] = measure_colony_sizes( plate, varargin )

    params = default_param( varargin, ...
        'manualGrid', false, ...
        'plateLoader', PlateLoader(), ...
        'thresholdMethod', fast_local_fitted(), ... 
        'sizeFunction', @threshold_bounded );
    
    % Make sure defaults are passed to other functions
    varargin = param_pairs( params );
    
    %% Load Plate
    if (ischar( plate ))
        % plate is file name
        plate = params.plateloader.load(plate);
        
    else
        % Crop plate
        if (size(plate,3) > 1)
            % Plate is assumed to be in RGB format
            warning('Assumptions were made concerning the plate format');
            plate = nanmean(plate,3);
            plate = crop_background( plate );
        end
    end
    
    %% Determine grid
    if isfield(params, 'grid')
        grid = params.grid;
    else
        if (params.manualgrid)
            % Manual Grid
            grid = manual_grid( plate, varargin{:} );
            if (isempty(grid))
                sizes = nan;
                grid = struct;
                return;
            end

        else
            % Auto Grid
            grid = auto_grid( plate, varargin{:} );
            
        end
    end
    
    grid.info.PlateLoader = params.plateloader;
    
    %% Intensity Thresholds
    if (~isfield(grid, 'thresh'))
        grid.thresh = params.thresholdmethod.apply_threshold(plate, grid);
        grid.info.ThresholdMethod = params.thresholdmethod;
    end
    
    %% Iterate over grid positions and measure colonies
    sizes = nan(grid.dims);
    for ii = 1 : prod(grid.dims)
        sizes(ii) = params.sizefunction( plate, grid, ii );
    end
    grid.params = params;
    grid.info.SizeFunction = params.sizefunction;
    
end