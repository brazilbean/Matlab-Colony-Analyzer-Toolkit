%% Load Plate
% Gordon Bean, February 2013

function [plate, grid] = load_plate( filename, varargin )
    params = default_param( varargin );
    
    if isfield( params, 'plateloader' )
        pl = params.plateloader;
        if exist([filename '.info.mat'],'file')
            grid = load([filename '.info.mat']);
        else
            grid = struct;
        end
    else
        % Look for grid information to load the image
        if exist([filename '.info.mat'],'file')
            grid = load([filename '.info.mat']);

            if isfield(grid, 'info') && isfield(grid.info, 'PlateLoader')
                plate = grid.info.PlateLoader(filename);
                return
            else
                pl = PlateLoader();
            end
        else
            % Otherwise, create a default PlateLoader
            pl = PlateLoader();
            if exist([filename '.info.mat'],'file')
                grid = load([filename '.info.mat']);
            else
                grid = struct;
            end
        end
    end
    
    plate = pl.load(filename);
    
end