%% Colony Quantifier - An abstract base class for quantification methods
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

classdef ColonyQuantifier < Closure
    properties
        label;
    end
    
    methods 
        function this = ColonyQuantifier( label )
            this = this@Closure();
            if (nargin < 1)
                label = 'size';
            end
            this.label = label;
        end

        function out = closure_method(this, varargin)
            out = this.quantify(varargin{:});
        end
%         function colsize = subsref(this, colony)
%             ii = achar('()', {colony.type});
%             if isempty(ii)
%                 % Attempting to access property
%                 colsize = this.(colony(1).subs);
%             else
%                 colsize = this.quantify(colony(ii).subs{:});
%             end
%         end
        
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
                
                % Ensure correct positioning
                if ~bbox(grid.win+1, grid.win+1)
                    % No colony in the middle, check for one nearby
                    w = (size(box,1)-1)/2;
                    
%                     bbox2 = bbox;
%                     bbox2([1:fix(w/2) end-fix(w/2):end],:) = false;
%                     bbox2(:,[1:fix(w/2) end-fix(w/2):end]) = false;
%                     
                    cents = component_props( clearborder(bbox) );
                    [val, jj] = min ...
                        ( sum(bsxfun(@minus, cents, [w+1 w+1]).^2,2) );
                    
                    if ~isempty(jj) && val < w/2
                        % Found another spot close to the center
                        row = grid.r(ii) + cents(jj,2) - w - 1;
                        col = grid.c(ii) + cents(jj,1) - w - 1;
                        
                        box = get_box( plate, row, col, grid.win );
                        if islogical(grid.thresh)
                            bbox = get_box ...
                                ( grid.thresh, row, col, grid.win );
                        else
                            bbox = box > grid.thresh(ii);
                        end
                    end
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