%% Re-adjust Grid - adjust the provided grid to the plate
% Matlab Colony Analyzer Toolkit
% Gordon Bean, September 2013
%
% This wrapper class is useful when you have starting grid that only needs
% to be slightly adjusted for the given plate.

classdef ReadjustGrid < Closure
    properties
        grid;
    end
    
    methods
        function this = ReadjustGrid( grid )
            this.grid = grid;
        end
        function out = closure_method( this, varargin )
            out = this.fit_grid(varargin{:});
        end
        function grid = fit_grid(this, plate)
            % Adjust the grid to the plate
            grid = adjust_grid(plate, this.grid, 'numMiddelAdjusts', 0);
        end
    end
end