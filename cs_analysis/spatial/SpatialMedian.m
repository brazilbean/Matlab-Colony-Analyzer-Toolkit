%% Spatial Median - a colony size spatial correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
%
% See also spatial_correction_tutorial.m

classdef SpatialMedian < Closure
    properties
        windowsize
        windowshape
        windowfun
        window
    end
    
    methods
        function this = SpatialMedian(varargin)
            this = this@Closure();
            this = default_param(this, ...
                'windowSize', 9, ...
                'windowShape', 'round', ...
                'windowFun', @nanmedian, ...
                'window', nan, ...
                varargin{:});
        end
        
        function fit = closure_method(this, varargin)
            fit = this.filter(varargin{:});
        end
        
        function fit = filter(this, colsizes)
            % Set up window
            if isnan(this.window)
                % No window provided, make one
                if strcmpi(this.windowshape, 'round')
                    % Make a round window
                    this.window = this.round_window( this.windowsize );

                elseif strcmpi(this.windowshape, 'square')
                    this.window = true( this.windowsize );

                else
                    error('Unrecognize value for WindowShape: %s', ...
                        this.windowshape);
                end
            end
            
            % Make sure colsizes is square
            n = numel(colsizes);
            dims = [8 12] .* sqrt( n / 96 );
            colsizes = reshape(colsizes, dims);
            
            fit = blockfun( colsizes, this.window, this.windowfun );
            
        end
        
        function window = round_window(this, diam )
            window = false(diam);
            [xx, yy] = meshgrid(1:size(window,1), 1:size(window,1));
            mid = ceil(size(window,1)/2);
            r = sqrt( floor(size(window,1)/2) * size(window,1)/2 );
            window( sqrt((xx-mid).^2 + (yy-mid).^2) <= r ) = true;
        end
    end
    
end
