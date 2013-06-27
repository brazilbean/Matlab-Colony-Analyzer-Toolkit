%% Colony Quantifier - An abstract base class for quantification methods
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

classdef ColonyQuantifier
    properties
        label;
    end
    
    methods 
        function this = ColonyQuantifier( label )
            if (nargin < 1)
                label = 'size';
            end
            this.label = label;
        end
        
        % Overload subsref
        function colsize = subsref(this, colony)
            ii = achar('()', {colony.type});
            if isempty(ii)
                % Attempting to access property
                colsize = this.(colony(1).subs);
            else
                colsize = this.quantify(colony(ii).subs{:});
            end
        end
        
        function colsize = quantify(this, varargin)
            colsize = nan;
        end
        
        function [box, bbox] = parse_box(this, varargin)
            if numel(varargin) == 3
                % Plate, grid, and index passed
                [plate, grid, ii] = deal(varargin{:});
                box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
            
                % Determine binary image
                if ~isfield(grid, 'thresh')
                    error('No threshold information available in grid');
                end
                if islogical(grid.thresh)
                    bbox = get_box ...
                        ( grid.thresh, grid.r(ii), grid.c(ii), grid.win );
                else
                    bbox = box > grid.thresh(ii);
                end
                
            elseif numel(varargin) == 2
                % Pixel and binary colony boxes passed
                [box, bbox] = deal(varargin{:});
                
            elseif numel(varargin) == 1
                % Binary colony box passed
                box = [];
                bbox = varargin{1};
                
            else
                error('Incorrect number of arguments: %i',numel(varargin));
            end
        end
    end
end 