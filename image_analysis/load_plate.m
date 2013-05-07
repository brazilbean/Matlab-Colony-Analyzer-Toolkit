%% Load Plate
% Gordon Bean, February 2013

function [plate, grid] = load_plate( filename, varargin )
    % Look for grid information to load the image
    if exist([filename '.info.mat'],'file')
        grid = load([filename '.info.mat']);
        
        if isfield(grid, 'info') && isfield(grid.info, 'PlateLoader')
            plate = grid.info.PlateLoader.load(filename);
            return
        end
    end
    
    % Otherwise, create a PlateLoader
    pl = PlateLoader(varargin{:});
    plate = pl.load(filename);
    
end