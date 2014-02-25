%% Border Median - a colony size border correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
%
% See also spatial_correction_tutorial.m

classdef BorderMedian < Closure
    properties
        depth
    end
    
    methods
        function this = BorderMedian(varargin)
            this = this@Closure();
            this = default_param(this, ...
                'depth', 4, ...
                varargin{:});
        end
        
        function fit = closure_method(this, varargin)
            fit = this.filter(varargin{:});
        end
        
        function fit = filter(this, colsizes)
            % Dimensions
            dims = [8 12] .* sqrt( numel(colsizes) / 96 );
            colsizes = reshape(colsizes, dims);
            
            % Plate median
            med = nanmedian(colsizes(:));
            
            % Allocate borders
%             [border1, border2] = deal(ones(dims) * med);
            [border1, border2] = deal(nan(dims));

            % Compute border medians
            d = this.depth;
            fun = @nanmedian;
            border1(end-d+1:end,:) = ...
                repmat(fun(colsizes(end-d+1:end,d+1:end-d),2),[1 dims(2)]);
            border1(1:d,:) = ...
                repmat(fun(colsizes(1:d,d+1:end-d),2),[1 dims(2)]);

            border2(:,end-d+1:end) = ...
                repmat(fun(colsizes(d+1:end-d,end-d+1:end),1),[dims(1) 1]);
            border2(:,1:d) = ...
                repmat(fun(colsizes(d+1:end-d,1:d),1),[dims(1) 1]);
            
            % Pick the border value in the intersecting regions
            fit = border1;
            iii = abs(border2-colsizes) < abs(border1-colsizes) ...
                | isnan(border1);
            fit(iii) = border2(iii);
            fit(isnan(fit)) = med;
        end
        
    end
    
end
