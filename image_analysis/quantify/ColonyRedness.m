%% Colony Redness - measures the redness of the colony
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Usage
% ------------------------------------------------------------------------
% colsize = ColonyRedness().quantify(plate, grid, position) % OR
% colsize = ColonyRedness().quantify(colony_box, binary_colony_box)
%
% CSI = ColonyRedness();
% colsize = CSI(plate, grid, position) % OR
% colsize = CSI(colony_box, binary_colony_box)
%

classdef ColonyRedness < ColonyQuantifier
    methods
        function this = ColonyRedness()
            this = this@ColonyQuantifier('redness');
        end
        
        function [colsize, bbox] = quantify(this, varargin)
            [box, bbox] = this.parse_box(varargin{:});
            
            % Remove adjacent colonies
            if isempty(box)
                % See usage.
                error('This method requires the pixel information.');
            end
            [~, bbox] = clear_adjacent_colonies(mean(box,3), bbox);
            
            % Average redness ratio
            box = double(box);
            redness = box(:,:,1) ./ mean(box(:,:,2:3),3);
            colsize = mean(redness(bbox(:)));
        end
    end
end