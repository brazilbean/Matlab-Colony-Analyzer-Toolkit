%% Background offset - a threshold based on the background intensity
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% Syntax
% BO = BackgroundOffset();
% BO = BackgroundOffset('Name', Value, ...);
%
% threshold = BO.determine_threshold( box );
% binary_image = BO.apply_threshold( plate, grid );
%
% Description
% BackgroundOffset inherits from ThresholdMethod.
%
% BO = BackgroundOffset() returns a BackgroundOffset object with the
% default parameters. BO = BackgroundOffset('Name', Value, ...) accepts
% name-value parameter pairs from the list below.
%
% THRESHOLD = BO.determine_threshold( BOX ) computes the pixel intensity
% threshold THRESHOLD using the 2D image BOX (typically BOX is a small
% window in PLATE centered on a colony - see get_box). 
%
% BINARY_IMAGE = BO.apply_threshold( PLATE, GRID ) returns the binary
% image BINARY_IMAGE, obtained by determining and then applying the
% threshold to a window surrounding each colony. 
%
% Parameters
% 'offset' <1.25>
%  - the factor multiplied by the background intensity to get the intensity
%  threshold.
% 'fullPlate' <false>
%  - if true, uses an adjusted algorithm for determining the background
%  intensity. Plates that have large colonies (nearly overgrown or larger)
%  should set this parameter to true.
%
% Algorithm
% BackgroundOffset determines the pixel intensity threshold of a small
% region (i.e. BOX) by multiplying the mode background intensity (found
% using a parzen-window convolution - see parzen_mode) with the offset
% parameter. Thus, the threshold is some scaling of the background pixel
% intensity at each position.
%
% See also ThresholdMethod

% (c) Gordon Bean, August 2013

classdef BackgroundOffset < ThresholdMethod
    properties
        offset;
        fullplate;
        background_max; % For internal use - not user-specified.
    end
    
    methods
        function this = BackgroundOffset( varargin )
            this = this@ThresholdMethod();
            this = default_param(this, ...
                'offset', 1.25, ...
                'fullplate', true, ...
                'background_max', nan, varargin{:} );
        end
        
        function thrplate = apply_threshold(this, plate, grid)
            if this.fullplate && isnan(this.background_max)
                % Calibrate background_max
                this = this.calibrate(plate, grid);
            end
            thrplate = apply_threshold@ThresholdMethod ...
                (this, plate, grid);
        end
        
        function this = calibrate(this, plate, grid)
            w = nanstd(grid.r(:));
            mid = get_box(plate, mean(grid.r(:)), mean(grid.c(:)), w);
                this.background_max = (min(mid(:)) + max(mid(:))) / 2;
        end
        
        function it = determine_threshold(this, box)
            if this.fullplate
                if isnan(this.background_max)
                    this.background_max = (min(box(:)) + max(box(:))) / 2;
                end
                
                % Estimate background
                bg = parzen_mode(box(box < this.background_max));
                
            else
                % Estimate background
                bg = parzen_mode(box(:));
    
            end
            
            % Return threshold
            it = bg * this.offset;
        end
    end
    
end