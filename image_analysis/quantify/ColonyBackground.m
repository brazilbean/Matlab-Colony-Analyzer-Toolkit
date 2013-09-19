%% Colony Background - measures the background intensity of the colony
% Matlab Colony Analyzer Toolkit
% Gordon Bean, September 2013
%
% Usage
% ------------------------------------------------------------------------
% colsize = ColonyBackground().quantify(plate, grid, position) % OR
% colsize = ColonyBackground().quantify(colony_box, binary_colony_box)
%
% CB = ColonyBackground();
% colsize = CB(plate, grid, position) % OR
% colsize = CB(colony_box, binary_colony_box)
%

classdef ColonyBackground < ColonyQuantifier
    methods
        function this = ColonyBackground()
            this = this@ColonyQuantifier('background');
        end
        
        function background = quantify(this, varargin)
            [box, bbox] = this.parse_box(varargin{:});
            
            % Compute background
            background = nanmean(box(~bbox));
        end
    end
end