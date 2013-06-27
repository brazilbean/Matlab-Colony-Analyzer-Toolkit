%% Colony Sum Intensity - measures the sum intensity of the colony
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Usage
% ------------------------------------------------------------------------
% colsize = ColonySumIntensity().quantify(plate, grid, position) % OR
% colsize = ColonySumIntensity().quantify(colony_box, binary_colony_box)
%
% CSI = ColonySumIntensity();
% colsize = CSI(plate, grid, position) % OR
% colsize = CSI(colony_box, binary_colony_box)
%

classdef ColonySumIntensity < ColonyQuantifier
    methods
        function this = ColonySumIntensity()
            this = this@ColonyQuantifier('sumintensity');
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
            colsize = sum(box(bbox(:)));
        end
    end
end