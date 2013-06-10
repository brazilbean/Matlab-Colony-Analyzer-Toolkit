%% Distance Max - Threshold Method
% Gordon Bean, May 2013

classdef distance_max < threshold_method
    properties
        min_window;
        dist_window;
        offset;
    end
    
    methods
        function this = distance_max( varargin )
            this = this@threshold_method();
            this = default_param( this, ...
                'min_window', 9, ...
                'dist_window', 0.5, ...
                'offset', 0, varargin{:} );
        end
        
        function it = determine_threshold(this, box)
            %% Distance from center
            w = size(box,1);
            [cc, rr] = meshgrid(1:w, 1:w);
            rr = rr - (w-1)/2;
            cc = cc - (w-1)/2;
            d = sqrt(rr.^2 + cc.^2);
            
            %% Smoothed max intensity vs distance
            dd = min(d(:)):max(d(:));
            dw = this.dist_window;
            foo = nan(size(dd));
            for jj = 1 : length(dd)
                list = abs(d - dd(jj)) < dw;
                foo(jj) = max(box(list));
            end

            %% Find mins
            mw = this.min_window;
            pos = mw + 1;
            pos = argmin(foo(pos-mw:pos+mw))+pos-mw-1;
            pos2 = 0;
            while pos > mw && pos < length(foo)-mw && pos2 ~= pos
                pos2 = pos;
                pos = argmin(foo(pos-mw:pos+mw))+pos-mw-1;
            end
            it = foo(pos);
            
            %% Check for empty spot
            pm = fastmode(box(:));
            tmp = box(box<pm)-pm;
            st = std([tmp;-tmp]);
            
            if abs(it - pm) < st
                it = max(box(:));
            end
            it = it + this.offset;

        end
        
        
    end
end