%% RawLocalFitted - a threshold based on the distribution of background
% Matlab Colony Analyzer Toolkit
% Gordon Bean, April 2014
%
% Syntax
% RLF = RawLocalFitted();
% RFL = RawLocalFitted('Name', Value, ...);
%
% threshold = RFL.determine_threshold( box );
% binary_image = RFL.apply_threshold( plate, grid );
%
% Description
% RawLocalFitted inherits from ThresholdMethod. It is designed to work with
% RAW images.
%
% RFL = RawLocalFitted() returns a RawLocalFitted object with the
% default parameters. RFL = RawLocalFitted('Name', Value, ...) accepts
% name-value parameter pairs from the list below.
%
% THRESHOLD = RFL.determine_threshold( BOX ) computes the pixel intensity
% threshold THRESHOLD using the 2D image BOX (typically BOX is a small
% window in PLATE centered on a colony - see get_box). 
%
% BINARY_IMAGE = RFL.apply_threshold( PLATE, GRID ) returns the binary
% image BINARY_IMAGE, obtained by determining and then applying the
% threshold to a window surrounding each colony. 
%
% Parameters
%  'numdevs' <3> scalar - the number of standard deviations above the lower
%  pixel intensity mode to call the threshold.
%  'windowscale' <1> scalar - scales the window around each colony to
%  define the "local" region. For sparse formats (i.e. 96, maybe 384), set
%  this value to less than 1 to improve the local fit. 
%
% Algorithm
% RawLocalFitted determines the pixel intensity threshold of a small
% region (i.e. BOX) using the same approach as LocalFitted.
%
% See also ThresholdMethod, LocalFitted

classdef RawLocalFitted < ThresholdMethod
    properties
        numdevs
        windowscale
    end
    
    methods
        function this = RawLocalFitted( varargin )
            this = this@ThresholdMethod();
            this = default_param( this, ...
                'numdevs', 3, ...
                'windowscale', 1, ...
                varargin{:});
        end
        
        function box = get_colony_box(this, plate, grid, row, col)
            % Default is to use grid.win.
            box = get_box(plate, ...
                grid.r(row, col), grid.c(row, col), ...
                grid.win*this.windowscale);
        end
        
        function it = determine_threshold(this, box)
            % Determine initial threshold
            tmp = prctile(box(:), [3 97]);
            it = mean(tmp);

            % Find mode of background pixels
            bm = parzen_mode(box(box < it));
            
            % Find standard deviation of background
            tmp = box(box < bm) - bm;
            
            % Return threshold
            it = bm + std([tmp; -tmp])*this.numdevs;
        end
    end
    
end