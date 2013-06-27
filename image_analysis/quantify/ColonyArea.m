%% Colony Area - measures the area (in pixels) of the colony
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Usage
% ------------------------------------------------------------------------
% colsize = ColonyArea().quantify(plate, grid, position) % OR
% colsize = ColonyArea().quantify(colony_box, binary_colony_box)
%
% CA = ColonyArea();
% colsize = CA(plate, grid, position) % OR
% colsize = CA(colony_box, binary_colony_box)
%

classdef ColonyArea < ColonyQuantifier
    methods
        function this = ColonyArea()
            this = this@ColonyQuantifier('area');
        end
        
        function [colsize, bbox] = quantify(this, varargin)
            [box, bbox] = this.parse_box(varargin{:});
            
            % Remove adjacent colonies
            if isempty(box)
                % See usage.
                error('This method requires the pixel information.');
            end
            [~, bbox] = clear_adjacent_colonies(box, bbox);
            
            % Sum area
            colsize = sum(bbox(:));
        end
    end
end