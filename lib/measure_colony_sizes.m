%% Measure Colony Sizes
%  Matlab Colony Analyzer Toolkit
%  Gordon Bean, December 2012
%
% Measures the sizes of colonies in the image.
% First argument may be the image data or a file name.
%
% Usage
% ------------------------------------------------------------------------
% [sizes, grid] = measure_colony_sizes( plate_, ... )
%  - PLATE_ is the plate image.
%  - SIZES is a matrix containing the colony sizes (or an array of matrices
%  containing colony sizes if multiple size functions were provided).
%  - GRID is the colony grid struct generated and used in the analysis.
%
% Parameters
% ------------------------------------------------------------------------
% grid 
%  - May be either a struct or a grid-fitting method
%   If it is a struct, that struct will be used as the grid
%   If it is a grid-fitting method, that method will be used to determine
%    the grid.
% plateLoader <PlateLoader()>
%  - the PlateLoader object used to load the images. The value passed
%  should be an instance of an object that extends PlateLoader.
% threshold <background_offset()>
%  - the ThresholdMethod object used to determine and apply the
%  pixel-intensity threshold to the image. The value passed should be an
%  instance of an object that extends ThresholdMethod.
% metric <@threshold_bounded>
%  - a function handle to the method that quantifies the colony size. This
%  method accepts the plate, grid, and position index (of the colony to be
%  quantified) and returns a single value. 
%  A cell array of function handles can be provided, in which case a cell
%  array of matrices will be returned (each containing the values returned
%  by each function handle). 
% loadGridCoords <false>
%  - if true, the grid coordinate information will be loaded from the
%  existing .info.mat file before the image is processed.
%
% All parameters are passed to auto_grid and manual_grid.
%
% See also OffsetAutoGrid, ManualGrid, ThresholdMethod, PlateLoader,
% threshold_bounded

function [sizes, grid] = measure_colony_sizes( plate_, varargin )

    params = default_param( varargin, ...
        'plateLoader', PlateLoader(), ...
        'threshold', BackgroundOffset(), ... 
        'metric', ColonyArea(), ...
        'loadGridCoords', false );
    
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
        if isstruct(params.grid)
            % An actual grid struct was provided, use it
            grid = params.grid;
        else
            % Assume a grid-fitting method was provided
            grid = params.grid(plate);
        end
        
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
        grid.info.loadgridcoords = true;
        
    else
        % Use the default grid method
        grid = OffsetAutoGrid().fit_grid(plate);
        
    end
    
    grid.info.PlateLoader = params.plateloader;
    
    %% Intensity Threshold
    if (~isfield(grid, 'thresh'))
        grid.thresh = params.threshold.apply_threshold(plate, grid);
        grid.info.Threshold = params.threshold;
    end
    
    %% Iterate over grid positions and measure colonies
    if iscell(params.metric)
        % Multiple quantification methods
        sizes = cell(size(params.metric));
        for jj = 1 : numel(sizes)
            sizes{jj} = nan(grid.dims);
            for ii = 1 : prod(grid.dims)
                sizes{jj}(ii) = params.metric{jj}( plate, grid, ii );
            end
        end
    else
        % Single quantification method
        sizes = nan(grid.dims);
        for ii = 1 : prod(grid.dims)
            sizes(ii) = params.metric( plate, grid, ii );
        end
    end
    grid.info.metric = params.metric;
    
end