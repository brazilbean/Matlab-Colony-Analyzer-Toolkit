%% Spatial Border Median - a colony size spatial and border correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
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
