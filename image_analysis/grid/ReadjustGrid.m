%% Re-adjust Grid - adjust the provided grid to the plate
% Matlab Colony Analyzer Toolkit
% Gordon Bean, September 2013
%
% This wrapper class is useful when you have starting grid that only needs
% to be slightly adjusted for the given plate.

classdef ReadjustGrid < Closure
    properties
        grid;
        numadjusts;
    end
    
    methods
        function this = ReadjustGrid( grid, varargin )
            this.grid = grid;
            this = default_param(this, ...
                'numAdjusts', 1, ...
                varargin{:});
        end
        function out = closure_method( this, varargin )
            out = this.fit_grid(varargin{:});
        end
        function grid = fit_grid(this, plate)
            grid = this.grid;
            for ii = 1 : this.numadjusts
                % Adjust the grid to the plate
                grid = adjust_grid(plate, grid, 'numMiddelAdjusts', 0);
            end
        end
    end
end