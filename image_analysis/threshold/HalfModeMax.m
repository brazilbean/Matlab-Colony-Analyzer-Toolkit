%% Half Mode+Max - a threshold based on the background intensity
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% Syntax
% HMM = HalfModeMax();
% HMM = HalfModeMax('Name', Value, ...);
%
% threshold = HMM.determine_threshold( box );
% binary_image = HMM.apply_threshold( plate, grid );
%
% Description
% HalfModeMax inherits from BackgroundOffset.
%
% HMM = HalfModeMax() returns a HalfModeMax object with the
% default parameters. HMM = HalfModeMax('Name', Value, ...) accepts
% name-value parameter pairs from the list below.
%
% THRESHOLD = HMM.determine_threshold( BOX ) computes the pixel intensity
% threshold THRESHOLD using the 2D image BOX (typically BOX is a small
% window in PLATE centered on a colony - see get_box). 
%
% BINARY_IMAGE = HMM.apply_threshold( PLATE, GRID ) returns the binary
% image BINARY_IMAGE, obtained by determining and then applying the
% threshold to a window surrounding each colony. 
%
% Parameters
% 'offset' < 1.0 >
%  - the factor multiplied by the background intensity to get the intensity
%  threshold.
% 'fullPlate' <false>
%  - if true, uses an adjusted algorithm for determining the background
%  intensity. Plates that have large colonies (nearly overgrown or larger)
%  should set this parameter to true.
%
% Algorithm
% HalfModeMax determines the pixel intensity threshold of a small
% region (i.e. BOX) by taking the average of the mode background intensity 
% (found using a parzen-window convolution - see parzen_mode) with the
% maximum pixel intensity in the region. This value can then be scaled by
% the optional parameter 'offset'. 
%
% See also ThresholdMethod

classdef HalfModeMax < BackgroundOffset
    properties
        % All inherited
    end
    
    methods
        function this = HalfModeMax( varargin )
            this = this@BackgroundOffset();
            this = default_param(this, ...
                'offset', 1, ...
                'fullplate', false, ...
                'background_max', nan, varargin{:} );
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
            % Estimate max
            mx = max(box(:));

            % Return threshold
            it = (bg + mx)/2 * this.offset;
        end
    end
    
end