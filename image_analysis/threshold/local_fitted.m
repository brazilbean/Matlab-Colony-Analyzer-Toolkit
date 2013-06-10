%% Local Intensity-fitted Method, subclass of threshold_method
% Gordon Bean, March 2013

classdef local_fitted < threshold_method
    properties
        pthresh;
    end
    
    methods
        % Constructor
        function this = local_fitted(pthr)
            % Check for dependencies
            deps = {'parzen_mode'};
            for dep = deps
                if ~exist(dep{:}, 'file')
                    error('LOCAL_FITTED requires the method %s. \n%s', ...
                        upper(dep{:}), ...
                        'Please add this method to your path.');
                end
            end
            
            % Superclass constructor
            this = this@threshold_method();
            
            % Local stuff
            if (nargin < 1)
                this.pthresh = 4.5;
            else
                this.pthresh = pthr;
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

            % Compute p-values
            pvals = this.get_pvals( box, bpm, st );

            % Threshold
            bb = pvals > this.pthresh;
            it = min( box(bb) ) - 1;
            
            if (isempty(it))
                it = nan;
            end
            
        end
        
        % Local fitted methods
        function [pm, st] = get_pm_std(~, box )
            it = (max(box(:)) + min(box(:)))/2;
            pm = parzen_mode(box(:));
            c = 5;
            while (c > 0 && pm > it)
                it = (it + min(box(:)))/2;
                pm = parzen_mode(box(box<it));
                c = c - 1;
            end
            tmp = box(box<pm)-pm;
            st = std([tmp;-tmp]);
        end

        function pv = get_pvals(~, b, bpm, st )
            pv = -log( 1 - normcdf( b-bpm, 0, st ) )./log(10);
        end

    end
    
end