%% Background offset - a threshold based on the background intensity
% Gordon Bean, May 2013

classdef background_offset < threshold_method
    properties
        offset;
    end
    
    methods
        function this = background_offset( offset )
            if (nargin < 1)
                offset = 1.25;
            end
            this.offset = offset;
        end
        
        function it = determine_threshold(this, box)
            % Estimate background
            bg = parzen_mode(box(:));
            
            % Return threshold
            it = bg * this.offset;
        end
    end
    
    
end