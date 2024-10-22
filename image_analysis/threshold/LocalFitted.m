%% Local Intensity-fitted Method, subclass of threshold method
% Gordon Bean, May 2013

classdef LocalFitted < ThresholdMethod
    properties
        bins;
        pvalue;
        fdr;
        fast;
        full;
        num_background_iters;
        upper_threshold_function;
    end
    
    methods
        % Constructor
        function this = LocalFitted(varargin)
            % Superclass constructor
            this = this@ThresholdMethod();
            
            % Local stuff
            this = default_param( this, ...
                'bins', 50 : 20 : 200, ...
                'pvalue', 0.001, ...
                'fdr', nan, ...
                'fast', true, ...
                'full', false, ...
                'num_background_iters', 5, ...
                'upper_threshold_function', @(x)nan, ...
                varargin{:});
            
            % Full plate settings
            tmp = varargin(cellfun(@ischar, varargin));
            if this.full && ~any(strcmpi('upper_threshold_function',tmp))
                % If the full parameter is true and a custom
                % upper-threshold-function was not provided...
                this.upper_threshold_function = ...
                    @(box)(min(box(:))+max(box(:)))/2;
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
        
        function it = determine_threshold( this, box )
            % Fit background pixels
            [bpm, st] = this.get_pm_std( box );
            
            if ~isnan(this.fdr)
                % Use FDR method
                xx = linspace(min(box(:)), max(box(:)), 200);
                yy = normpdf(xx, bpm, st);

                % Estimate intensity threshold
                [n, xb] = hist(box(:), floor(numel(box)/100));
                h = interp1(xb, n, bpm);
                yy = yy./max(yy) * h;

                nn = interp1( xb, n, xx );
                it = xx(find( xx > bpm & yy./nn < this.fdr, 1 ));
    %             it = xx(find( xx > bpm & yy < (nn-yy)*this.factor, 1 ));
            else
                % Use p-value method (default)
                it = bpm - norminv(this.pvalue)*st;
                
            end
            if (isempty(it))
                it = nan;
            end

        end
        
        function thrplate = apply_threshold( this, plate, grid )
            thrplate = false(size(plate));
            for r = 1 : grid.dims(1)
                for c = 1 : grid.dims(2)
                    box = this.get_colony_box(plate, grid, r, c);
                    it = this.determine_threshold( box );
                    if (isnan(it))
                        it = max(plate(:));
                    end
                    thrplate = set_box(thrplate, box>it, ...
                        grid.r(r,c), grid.c(r,c));
                end
            end
        end
        
        % Local fitted methods
        function [pm, st] = get_pm_std(this, box )
            it = this.upper_threshold_function(box);
            if this.fast
                pm = this.fastmode(box(:));
            else
                pm = parzen_mode(box(:));
            end
            
            if ~isnan(it)
                c = this.num_background_iters;
                while (c > 0 && pm > it)
                    it = (it + min(box(:)))/2;
                    pm = this.fastmode(box(box<it));
                    c = c - 1;
                end
            end
            
            tmp = box(box<pm)-pm;
            st = std([tmp;-tmp]);
        end
        
        function m = fastmode(this, data, bins )
%             m = parzen_mode(data(:));
        
            if (nargin < 3)
                bins = this.bins;
            end

            mxs = nan(size(bins));
            mnb = min(data(:));
            mxb = max(data(:));
            for ii = 1 : length(bins)
                x = linspace(mnb, mxb, bins(ii));
                n = histc(data(:), x );
                [~,mi] = max(n);
                mxs(ii) = x(mi);
            end
            m = mean(mxs);

        end
        
    end
    
end