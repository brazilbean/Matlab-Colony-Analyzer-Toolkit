%% Intensity Threshold Class: Max-Min Mean
% Gordon Bean, March 2013

classdef MaxMinMean < ThresholdMethod
    
    properties
        % None
    end
    
    methods
        % Constructor
        function this = MaxMinMean()
            % Check for dependencies
            % No non-standard dependencies
            this = this@ThresholdMethod();
        end
        
        % Inherited methods
        function box = get_colony_box(~, plate, grid, row, col )
            box = get_box ...
                (plate, grid.r(row,col), grid.c(row,col), grid.win);
        end
        
        function it = determine_threshold(~, box )
            % To be implemented by subclasses
            it = ( max( box(:) ) + min( box(:) ) ) / 2;
        end
    end
    
end

%% Heritage code
% it = max_min_mean( box )
% 
% m = round(size(box)/2);
% mm = round( size(box)/4 );
% 
% mid = false(size(box));
% mid(m-mm:m+mm,m-mm:m+mm) = true;
% 
% %     it = ( prctile( box(:), 99.9 ) + parzen_mode(box(:)) ) / 2;
% %     it = ( max( box(:) ) + min( box(:) ) ) / 2;
% it = ( max( box(:) ) + median( box(~mid) ) ) / 2;
% 
% if ( sum(box(mid)>it) / sum(mid(:)) ...
%         < sum(box(~mid)>it) / sum(~mid(:)))
%     % Empty spot
%     it = max(box(:));
% end
