%% Measure Colony Sizes
% Gordon Bean, December 2012
%
% Measures the sizes of colonies in the image.
% First argument may be the image data or a file name.

function [sizes, grid] = measure_colony_sizes( plate, varargin )

    params = get_params( varargin{:} );
    params = default_param( params, 'sizeFunction', ...
        @colony_box_method );
    params = default_param( params, 'manualGrid', false );
    params = default_param( params, 'localThreshold', false );
    params = default_param( params, 'sparsePlate', false );
    
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
            params = default_param( params, 'grid', ...
                determine_colony_grid( plate, varargin{:} ) );
        end
    end
    
    grid = params.grid;
    
    %% Global Intensity Threshold
    if (params.sparseplate)
        % No global threshold
        % Note, results will be overriden by localThreshold = true
        grid.thresh = nan;
    else
        % Keep global threshold
    end
    
    %% Local intensity threshold
    if (params.localthreshold)
        grid.thresh = compute_local_thresholds( plate, grid, varargin{:} );
        grid.info.localthreshold = true;
    else
        if (numel(grid.thresh) == 1)
            grid.thresh = repmat( grid.thresh, grid.dims );
        end
    end
    
    %% Iterate over grid positions and measure colonies
    sizes = nan(grid.dims);
    grid.threshed = false(size(plate));
    
    if ischar(params.sizefunction)
        if (strcmpi(params.sizefunction, 'localfitted'))
            [sizes, grid.threshed] = local_intensity_fitted_method ...
                (plate, grid);
        end
    else
        for rr = 1 : grid.dims(1)
            for cc = 1 : grid.dims(2)
                box = get_box ...
                    ( plate, grid.r(rr,cc), grid.c(rr,cc), grid.win);
                [sizes(rr,cc), b] = params.sizefunction ...
                    ( box, grid.thresh(rr,cc) );
                grid.threshed = set_box ...
                    ( grid.threshed, b, grid.r(rr,cc), grid.c(rr,cc) );
            end
        end
        if (~any(grid.threshed(:)))
            pthresh = make_plate_threshold( plate, grid );
            grid.treshed = plate > pthresh;
        end
    end
    sizes = sizes(:);
    grid.params = params;
    
end