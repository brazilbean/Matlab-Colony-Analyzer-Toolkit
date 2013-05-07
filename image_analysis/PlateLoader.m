%% PlateLoader Class
% Gordon Bean, May 2013

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