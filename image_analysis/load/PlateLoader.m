%% PlateLoader Class
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% This object is used to load plate images. It can be extended to create
% custom image-loading functionality.
%
% Syntax
% PL = PlateLoader();
% PL = PlateLoader('Name', Value, ...);
% plate = PL(img);
% plate = PL.load(img);
% plate = PlateLoader(...).load(img);
%
% Description
% PL = PlateLoader() returns a PlateLoader object with the default
% parameters. PL = PlateLoader('Name', Value, ...) accepts name-value pairs
% from following list (defaults in <>):
%  'channel' <1:3> - indicates which of the RBG channels to process.
%
%  'crop' - a 4-element vecor indicating the region to be cropped: 
%    [row_min row_max col_min col_max].
%
%  'rotate90' - an integer 'k' indicating the k*90 degree rotation to apply
%  to the cropped image. Positive values rotate counterclockwise, negative
%  values rotate clockwise.
%
%  'autoRotate' <true> - if 'rotate90' is not specified and 'autoRotate' is
%  true, the cropped image is rotated counterclockwise by 90 degrees.
%
%  'interp' - a scalar indicating the number of times to downsample the
%  resolution of the image (using interp2). You probably won't use this.

classdef PlateLoader < Closure
    properties
        channel
        allowrotate
        autorotate
        crop
        rotate90
        interp
    end
    
    methods
        function this = PlateLoader(varargin)
            params = default_param( varargin, ...
                'channel', 1:3, ...
                'autorotate', true, ...
                'allowrotate', true, ...
                'crop', [], ...
                'rotate90', 0, ...
                'interp', 0);
            
            for prop = properties('PlateLoader')'
                this.(prop{:}) = params.(prop{:});
            end
            % For backwards compatibility
            % If allowrotate and autorotate refer to the same thing
            % If either is false (non-default), set auto-rotate to false
            if ~this.autorotate || ~this.allowrotate
                this.autorotate = false;
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
            
            % Average across channels
            img = mean(img(:,:,this.channel),3);
            
            % Crop background
            if isempty(this.crop)
                plate = crop_background( img );
            else
                plate = img ...
                    (this.crop(1):this.crop(2), this.crop(3):this.crop(4));
            end
            
            % Rotate if img is in portrait mode
            if ~this.rotate90 && ... No auto if specific rotation specified
                    this.autorotate && size(plate,1) > size(plate,2)
                plate = rot90(plate);
            end
            
            % Rotate
            if this.rotate90 ~= 0
                plate = rot90(plate, this.rotate90);
            end
            
            % Resample
            if this.interp > 0
                plate = interp2(plate, this.interp);
            end
            
        end
    end
end