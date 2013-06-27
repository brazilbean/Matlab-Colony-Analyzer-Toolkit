%% Half Mode+Max - a threshold based on the background intensity
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