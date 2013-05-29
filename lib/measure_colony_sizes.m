%% Measure Colony Sizes
% Gordon Bean, December 2012
%
% Measures the sizes of colonies in the image.
% First argument may be the image data or a file name.

function [sizes, grid] = measure_colony_sizes( plate_, varargin )

    params = default_param( varargin, ...
        'manualGrid', false, ...
        'plateLoader', PlateLoader(), ...
        'thresholdMethod', background_offset(), ... 
        'sizeFunction', @threshold_bounded, ...
        'loadGridCoords', false );
    
    % Make sure defaults are passed to other functions
    varargin = param_pairs( params );
    
    %% Load Plate
    if (ischar( plate_ ))
        % plate is file name
        plate = params.plateloader.load(plate_);
        
    else
        % Crop plate
        plate = plate_;
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
    elseif params.loadgridcoords
        % Load the grid coordinates from file
        if ~ischar(plate_)
            error('To use loadGridCoords you must provide the file name');
        end
        [~,grid_] = load_plate( plate_ );
        if isempty(fieldnames(grid_))
            error('No grid file found.');
        end
        grid.r = grid_.r;
        grid.c = grid_.c;
        grid.win = grid_.win;
        grid.dims = grid_.dims;
        grid.factors = grid_.factors;
        grid.info.theta = grid_.info.theta;
        grid.info.fitfunction = grid_.info.fitfunction;
        
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