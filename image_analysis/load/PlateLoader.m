%% PlateLoader Class
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% This object is used to load plate images. It can be extended to create
% custom image-loading functionality.
%
% Parameters
% ------------------------------------------------------------------------
% channel <1:3>
%  - indicates which of the RBG channels to process
% allowRotate <true>
%  - the default behavior of PlateLoader is to rotate the image by 90
%  degrees if the image is in portrait mode. If allowRotate is false, the
%  image will not be rotated.
%

classdef PlateLoader
    properties
        channel
        allowrotate
    end
    
    methods
        function this = PlateLoader(varargin)
            params = default_param( varargin, ...
                'channel', 1:3, ...
                'allowrotate', true );
            for prop = properties('PlateLoader')'
                this.(prop{:}) = params.(prop{:});
            end
        end
        
        function plate = load( this, filename )
            % Read file
            img = imread(filename);
            if isa(img, 'uint16')
                % some toolkit functions require single or double
                img = single(img); 
            end
            
            % Average across channels
            img = mean(img(:,:,this.channel),3);
            
            % Rotate if img is in portrait mode
            if this.allowrotate && size(img,1) > size(img,2)
                img = rot90(img);
            end
            
            % Crop background
            plate = crop_background( img );
            
        end
    end
end