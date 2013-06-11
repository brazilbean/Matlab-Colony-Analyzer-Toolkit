%% Background offset - a threshold based on the background intensity
% Gordon Bean, May 2013

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
                'fullplate', false, ...
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
                % Estimate background
                bg = parzen_mode(box(box < this.background_max));
                
                % Return threshold
                it = bg * this.offset;
            else
                % Estimate background
                bg = parzen_mode(box(:));

                % Return threshold
                it = bg * this.offset;
            end
        end
    end
    
    
end