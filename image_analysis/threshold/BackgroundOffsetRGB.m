%% Background offset RGB - a threshold based on the background intensity
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% Parameters
% ------------------------------------------------------------------------
% offset <1.25}
%  - the factor multiplied by the background intensity to get the intensity
%  cutoff.
% fullPlate <false>
%  - if true, uses an adjusted algorithm for determining the background
%  intensity. Plates that have large colonies (nearly overgrown or larger)
%  should set this parameter to true.
% background_max <nan>
%  - a parameter for internal use - this is set when apply_threshold is
%  called.
%
% See also ThresholdMethod

% (c) Gordon Bean, August 2013

classdef BackgroundOffsetRGB < BackgroundOffset
    methods
        function this = BackgroundOffsetRGB( varargin )
            this = this@BackgroundOffset( ...
                'offset', 1.25, ...
                'fullplate', true, ...
                'background_max', nan, varargin{:} );
        end
        
        function thrplate = apply_threshold(this, plate, grid)
            thrplate = apply_threshold@BackgroundOffset(this, ...
                mean(plate,3), grid);
        end
        
        function this = calibrate(this, plate, grid)
            this = calibrate@BackgroundOffset(this, mean(plate,3), grid);
        end
        
    end
    
end