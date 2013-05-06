%% Load Plate
% Gordon Bean, February 2013

function [plate, grid] = load_plate( filename, varargin )
    params = default_param( varargin, ...
        'channel', 1:3, ... % Red, Green, Blue
        'rotate', true ); 
    
    img = imread(filename);
    if isa(img, 'uint16')
        img = single(img);
    end
    
    % Average across channels
    img = mean(img(:,:,params.channel),3);
    
    % Rotate if img is in portrait mode
    if params.rotate && size(img,1) > size(img,2)
        img = rot90(img); % Rotate
    end
    
    % Crop background
    plate = crop_background(img);
    
    % Load grid if requested
    if (nargout > 1)
        grid = load([filename '.info.mat']);
    end
end