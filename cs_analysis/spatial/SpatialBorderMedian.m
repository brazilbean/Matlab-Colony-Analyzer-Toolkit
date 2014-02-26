%% Spatial Border Median - a colony size spatial and border correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
%
% Syntax
% SBM = SpatialBorderMedian();
% SBM = SpatialBorderMedian('Name', Value, ...);
% spatial = SBM.filter(plate);
% spatial = SMF(plate);
% spatial = SpatialBorderMedian(...).filter(plate);
%
% SBM = SpatialBorderMedian() returns a SpatialBorderMedian object with the
% default parameters. This object can be used as a regular object (SPATIAL 
% = SBM.filter(PLATE)) or like a function handle (SPATIAL = SBM(PLATE)).
%
% SM = SpatialMedian('Name, Value, ...) accepts parameter name-value pairs
% from the following list (defaults in {}):
%  'SpatialFilter' {SpatialMedian()} - a spatial filter object (see
%  cs_analysis/spatial/ in the Matlab Colony Analyzer Toolkit for options).
%  
%  'BorderFilter' {BorderMedian()} - a border filter object (see
%  cs_analysis/spatial/ in the Matlab Colony Analyzer Toolkit for options).
%
% Algorithm
% The SpatialBorderMedian algorithm estimates spatial and border effects
% simultaneously, and is a little more accurate than using the spatial and
% border filters sequentially.
%
% First, the spatial filter is applied to obtain a preliminary spatial 
% correction. Then the border filter is applied to the plate divided by the
% spatial filter to obtain the border corerction. Finally, the spatial
% correction is applied to the original plate divided by the border
% correction to obtain the final spatial correction. The product of the
% spatial and border corrections is returned. 
%
% See also spatial_correction_tutorial.m

classdef SpatialBorderMedian < Closure
    properties
        spatialfilter
        borderfilter
    end
    
    methods
        function this = SpatialBorderMedian(varargin)
            this = this@Closure();
            this = default_param(this, ...
                'spatialFilter', SpatialMedian, ...
                'borderFilter', BorderMedian, ...
                varargin{:});
        end
        
        function fit = closure_method(this, varargin)
            fit = this.filter(varargin{:});
        end
        
        function fit = filter(this, plate)
            % Pre-spatial
            spatial = this.spatialfilter(plate);
            
            % Border
            border = this.borderfilter(plate./spatial);
            
            % Spatial
            spatial = this.spatialfilter(plate./border);
            
            % Return filter
            fit = border .* spatial;
 
        end
    end
end
