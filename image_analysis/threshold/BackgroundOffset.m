%% Background offset - a threshold based on the background intensity
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

classdef BackgroundOffset < ThresholdMethod
    properties
        offset;
        fullplate;
        background_max;
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
            mid = get_box(plate, mean(grid.r(:)), mean(grid.c(:)), ...
                    grid.win * 5);
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