%% Colony Diameter - measures the major axis length of the colony
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

classdef ColonyDiameter < ColonyQuantifier
    methods
        function this = ColonyDiameter()
            this = this@ColonyQuantifier('diameter');
        end
        
        function colsize = quantify(this, varargin)
            [box, bbox] = this.parse_box(varargin{:});
            
            % Clear adjacent colonies
            [~, bbox] = clear_adjacent_colonies(box, bbox);
            
            % Get colony properties
            stats = regionprops(bbox, 'Centroid', 'MajorAxisLength');

            % Identify the center colony
            cents = cat(1, stats.Centroid);
            w = (size(box,1)-1)/2+1;
            tmp = sum((cents - w).^2,2);

            % Return the diameter, or major axis length of the colony
            if isempty(stats)
                % Box is empty
                colsize = nan;
            else
                colsize = stats(argmin(tmp)).MajorAxisLength;
            end
        end
    end
end