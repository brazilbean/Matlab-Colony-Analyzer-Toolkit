%% PlateLoaderRGB Class
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% This object is used to load plate images that keep all 3 color channels
% (RGB).
%
% Parameters
% ------------------------------------------------------------------------
% channel <1:3>
%  - indicates which of the RBG channels to process
% allowRotate <true>
%  - the default behavior of PlateLoader is to rotate the image by 90
%  degrees if the image is in portrait mode. If allowRotate is false, the
%  image will not be rotated.
% crop <[]>
%  - may be a vector of 4 elements: [row_min, row_max, col_min, col_max]

% (c) Gordon Bean, August 2013

classdef PlateLoaderRGB < Closure
    properties
        channel
        allowrotate
        crop
        rotate90
        interp
    end
    
    methods
        function this = PlateLoaderRGB(varargin)
            params = default_param( varargin, ...
                'channel', 1:3, ...
                'allowrotate', true, ...
                'crop', [], ...
                'rotate90', 0, ...
                'interp', 0);
            for prop = properties('PlateLoader')'
                this.(prop{:}) = params.(prop{:});
            end
        end
        
        function out = closure_method(this, varargin)
            out = this.load(varargin{:});
        end
        
        function plate = load( this, filename )
            % Read file
            img = imread(filename);
            if isa(img, 'uint16')
                % some toolkit functions require single or double
                img = single(img); 
            end
            
            % Rotate if img is in portrait mode
            if this.allowrotate && size(img,1) > size(img,2)
                img = cat(3, rot90(img(:,:,1)), rot90(img(:,:,2)), ...
                    rot90(img(:,:,3)));
            end
            
            % Crop background
            if isempty(this.crop)
                [~, crop_] = crop_background( mean(img,3) );
                plate = img(crop_(1):crop_(2), crop_(3):crop_(4), :);
            else
                plate = img ...
                 (this.crop(1):this.crop(2), this.crop(3):this.crop(4), :);
            end
            
            % Rotate
            if this.rotate90 ~= 0
                plate = cat(3, rot90(plate(:,:,1), this.rotate90), ...
                    rot90(plate(:,:,2), this.rotate90), ...
                    rot90(plate(:,:,3), this.rotate90) );
            end
            
            % Resample
            if this.interp > 0
                plate = cat(3, interp2(plate(:,:,1), this.interp), ...
                    interp2(plate(:,:,2), this.interp), ...
                    interp2(plate(:,:,3), this.interp) );
            end
            
        end
    end
end