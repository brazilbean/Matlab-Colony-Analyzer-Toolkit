%% Threshold Method Parent Class
% Gordon Bean, March 2013
%
% ThresholdMethod is intended as an abstract class and is not useful for
% instantiation. 
%
% See also BackgroundOffset, BackgroundOffsetRGB, MaxMinMean, MinFrequency,
%  LocalFitted, HalfModeMax

classdef ThresholdMethod
   
    properties
        % None
    end
    
    methods
        function this = ThresholdMethod()
            % Initialize object 'this'
        end
        
        function box = get_colony_box(~, plate, grid, row, col)
            % Default is to use grid.win.
            box = get_box(plate, ...
                grid.r(row, col), grid.c(row, col), grid.win);
        end
        
        function it = determine_threshold(~, box )
            % To be implemented by subclasses
            it = nan;
        end
        
        function thrplate = apply_threshold( this, plate, grid )
            % Default 
            % - iterate through each position
            % - get box
            % - estimate threshold
            % - save thresholded box
            thrplate = false(size(plate));
            for r = 1 : grid.dims(1)
                for c = 1 : grid.dims(2)
                    box = this.get_colony_box(plate, grid, r, c);
                    it = this.determine_threshold( box );
                    thrplate = set_box(thrplate, box>it, ...
                        grid.r(r,c), grid.c(r,c));
                end
            end
        end
    end
    
end