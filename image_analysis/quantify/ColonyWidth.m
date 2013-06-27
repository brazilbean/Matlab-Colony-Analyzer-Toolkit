%% Colony Width - measures the middle horizontal width of the colony
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

classdef ColonyWidth < ColonyQuantifier
    methods
        function this = ColonyWidth()
            this = this@ColonyQuantifier('width');
        end
        
        function colsize = quantify(this, varargin)
            [box, bbox] = this.parse_box(varargin{:});
            
            % Clear adjacent colonies
            [~, bbox] = clear_adjacent_colonies(box, bbox);
            
            % Measure width
            mid = ceil(size(bbox,1)/2);
            colsize = sum(bbox(mid,:));

        end
    end
end