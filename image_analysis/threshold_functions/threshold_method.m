%% Threshold Method Parent Class
% Gordon Bean, March 2013

classdef threshold_method
   
    properties
        % None
    end
    
    methods
        function this = threshold_method()
            % Initialize object 'this'
        end
        function box = get_colony_box(~, plate, grid, row, col )
            % To be implemented by subclasses
            box = nan;
        end
        function it = determine_threshold(~, box )
            % To be implemented by subclasses
            it = nan;
        end
    end
    
end