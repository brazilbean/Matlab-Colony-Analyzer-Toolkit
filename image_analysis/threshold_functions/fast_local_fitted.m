%% Fast Local Intensity-fitted Method, subclass of threshold method
% Gordon Bean, May 2013

classdef fast_local_fitted < threshold_method
    properties
        pthresh;
        bins;
    end
    
    methods
        % Constructor
        function this = fast_local_fitted(pthr)
            
            % Superclass constructor
            this = this@threshold_method();
            
            % Local stuff
            if (nargin < 1)
                this.pthresh = 4.5;
                this.bins = 50 : 10 : 200;
            else
                this.pthresh = pthr;
                this.bins = 50 : 10 : 200;
            end
        end
        
        % Superclass methods
        function box = get_colony_box(~, plate, grid, row, col )
            % Determine window size
            win = grid.win;
            if (prod(grid.dims)==6144)
                win = grid.win*2;
            elseif (prod(grid.dims)==24576)
                win = grid.win*4;
            end

            % Get box
            box = get_box(plate, grid.r(row,col), grid.c(row,col), win);
            
        end
        
        function it = determine_threshold(this, box )
            % Fit background pixels
            [bpm, st] = this.get_pm_std( box );

            xx = linspace(min(box(:)), max(box(:)), 200);
            yy = normpdf(xx, bpm, st);
            
            % Estimate intensity threshold
            [n, xb] = hist(box(:), floor(numel(box)/100));
            h = interp1(xb, n, bpm);
            yy = yy./max(yy) * h;

            nn = interp1( xb, n, xx );
            it = xx(find( xx > bpm & yy < nn-yy, 1 ));
            
            if (isempty(it))
                it = max(box(:));
            end

        end
        
%         function it = determine_threshold(this, box )
%             % Fit background pixels
%             [bpm, st] = this.get_pm_std( box );
% 
%             % Compute p-values
%             pvals = this.get_pvals( box, bpm, st );
% 
%             % Threshold
%             bb = pvals > this.pthresh;
%             it = min( box(bb) ) - 1;
%             
%             if (isempty(it))
%                 it = nan;
%             end
%             
%         end
        
        % Local fitted methods
        function [pm, st] = get_pm_std(this, box )
            it = (max(box(:)) + min(box(:)))/2;
            pm = this.fastmode(box(:));
            c = 5;
            while (c > 0 && pm > it)
                it = (it + min(box(:)))/2;
                pm = this.fastmode(box(box<it));
                c = c - 1;
            end
            tmp = box(box<pm)-pm;
            st = std([tmp;-tmp]);
        end
        
        function pv = get_pvals(~, b, bpm, st )
            pv = -log( 1 - normcdf( b-bpm, 0, st ) )./log(10);
        end

        function m = fastmode(this, data, bins )
            if (nargin < 3)
                bins = this.bins;
            end

            mxs = nan(size(bins));
            for ii = 1 : length(bins)
                [n,x] = hist(data(:), bins(ii));
                [~,mi] = max(n);
                mxs(ii) = x(mi);
            end
            m = mean(mxs);

        end
        
    end
    
end