%% Spatial Median - a colony size spatial correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
%
% Syntax
% SM = SpatialMedian();
% SM = SpatialMedian('Name', Value, ...);
% spatial = SM(plate);
% spatial = SpatialMedian(...).filter(plate);
%
% Description
% SM = SpatialMedian() returns a SpatialMedian object with the default
% parameters. This object can be used as a regular object (SPATIAL =
% SM.filter(PLATE)) or like a function handle (SPATIAL = SM(PLATE)). 
% 
% PLATE should be a 2D matrix. If PLATE is a vector, SpatialMedian will
% attempt to reshape it into a standard microbial assay format (96-, 384-,
% 1536-, 6144-, etc., well format) and will throw an error if it fails. If
% PLATE is already 2D, no reshaping is done, and it does not have to have
% standard dimensions.
%
% SM = SpatialMedian('Name, Value, ...) accepts parameter name-value pairs
% from the following list (defaults in {}):
%  'WindowSize' {9} - a scalar or 2-element vector indicating the diameter 
%  or dimensions of the 2D sliding window (see Algorithms). The window is 
%  centered at ceil('WindowSize'/2). This value is ignored if 'Window' is
%  specified.
%
%  'WindowShape' {'round'} | 'square' - a string indicating the shape of
%  the 2D window. 'Round' uses a circular mask with a radius equal to the
%  geometric mean of the window dimensions. 'Square' uses a rectangular
%  window of the specified dimensions. This value is ignored if 'Window' is
%  specified.
%
%  'WindowFUn' {@nanmedian} - a function handle that is called on the
%  values of each 2D window.
%
%  'Window' - a 2D binary matrix that is used as the sliding window. If not
%  specified, this window is constructed using the values from
%  'WindowShape' and 'WindowSize'. 
%
%  'AcceptZeros' {false} - when regions of the plate have many zeros, the
%  median may be zero, which may result in division by zero and NaN and Inf
%  values. If false, then background values of zero are replaced by the
%  closest non-zero value to the median in that window. If true, nothing is
%  done to correct zero-values. Note that when there are not values other
%  than zero within a window, acceptZeros == false will result in NaN 
%  values in those positions.
%
% Algorithm
% SpatialMedian estimates the background pixel intensity at each position
% by executing 'WindowFun' on the values indicated by the binary matrix
% 'Window' centered at each position. 
%
% See also spatial_correction_tutorial, blockfun

classdef SpatialMedian < Closure
    properties
        windowsize
        windowshape
        windowfun
        window
        acceptzeros
        blockfunparams
    end
    
    methods
        function this = SpatialMedian(varargin)
            this = this@Closure();
            this = default_param(this, ...
                'windowSize', 9, ...
                'windowShape', 'round', ...
                'windowFun', @nanmedian, ...
                'window', nan, ...
                'acceptZeros', false, ...
                'blockFunParams', {}, ...
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
            
            % Make sure colsizes is rectangular
            if max(size(colsizes)) == numel(colsizes)
                n = numel(colsizes);
                dims = [8 12] .* sqrt( n / 96 );
                colsizes = reshape(colsizes, dims);
            end
            
            fit = blockfun( colsizes, this.window, this.windowfun, ...
                this.blockfunparams{:});
            
            % Correct for zeros in the background
            % Assumes that all values are positive.
            if ~this.acceptzeros
                iszero = find(fit == 0);
                if ~isempty(iszero)
                    fit(iszero) = blockfun( fil(colsizes, @(x) x<=0), ...
                        this.window, @this.abs_min, 'positions', iszero);
                end
            end
        end
        
        function window = round_window(~, diam )
            window = false(diam);
            [xx, yy] = meshgrid(1:size(window,1), 1:size(window,1));
            mid = ceil(size(window,1)/2);
            r = sqrt( floor(size(window,1)/2) * size(window,1)/2 );
            window( sqrt((xx-mid).^2 + (yy-mid).^2) <= r ) = true;
        end
        
        function val = abs_min(~, x)
            % If the median was zero, I want the closest non-zero value
            % (i.e. the closest to the median that is not zero). 
            [val, mi] = min(x);
            ii = sub2ind(size(x), mi, 1:size(x,2));
            val = val .* sign(x(ii));
        end
    end
    
end
