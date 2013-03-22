%% Load Plate
% Gordon Bean, February 2013

function [plate, grid] = load_plate( filename )
    plate = crop_background(mean(imread(filename),3));
    if (nargout > 1)
        grid = load([filename '.info.mat']);
    end
end