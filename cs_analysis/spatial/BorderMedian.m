%% Border Median - a colony size border correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
% 
% Syntax
% BM = BorderMedian();
% BM = BorderMedian('Name', Value, ...);
% border = BM(plate);
% border = BM.filter(plate);
% border = BorderMedian(...).filter(plate);
%
% Description
% BM = BorderMedian() returns a BorderMedian object that may be used as a
% regular object (BORDER = BM.filter(PLATE)) or like a function handle
% (BORDER = BM(PLATE)). 
%
% PLATE should be a 2D matrix. If PLATE is a vector, SpatialMedian will
% attempt to reshape it into a standard microbial assay format (96-, 384-,
% 1536-, 6144-, etc., well format) and will throw an error if it fails. If
% PLATE is already 2D, no reshaping is done, and it does not have to have
% standard dimensions.
%
% BM = BorderMedian('Name', Value, ...) accepts parameters from the
% following list (defaults in {}):
%  'depth' {4} - a scalar indicating the number of rows and columns
%  bordering the perimiter of the matrix to be evaluated.
%
% Algorithm
% The BorderMedian algorithm estimates the background intensity for rows
% and columns that are adjacent to the perimeter of the matrix. The
% background is estimated as the median of the repsective row or column. 
%
% The values for corner positions (where a value from the row and from the
% column are available) are assigned based on which row or column value is
% closest to the actual value in the cell. In other words, the row or
% column median that is closest to the value at a corner position is
% selected for that position.
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
            % Make sure colsizes is rectangular
            if max(size(colsizes)) == numel(colsizes)
                n = numel(colsizes);
                dims = [8 12] .* sqrt( n / 96 );
                colsizes = reshape(colsizes, dims);
            end
            
            % Plate median
            med = nanmedian(colsizes(:));
            
            % Allocate borders
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
