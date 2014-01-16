%% SpatialSurface - a spatial/border correction based on fitted surface
% Matlab Colony Analyzer Toolkit
% Gordon Bean, October 2013
%
% See also spatial_correction_tutorial.m

classdef SpatialSurface < Closure
    properties
        degree;
    end
    
    methods
        function this = SpatialSurface(varargin)
            this = this@Closure();
            this = default_param(this, ...
                'degree', 7, varargin{:});
        end
        
        function fit = closure_method(this, varargin)
            fit = this.filter(varargin{:});
        end
        
        function fit = filter(this, colsizes)
            fit = surfacefit( colsizes, 'degree', this.degree );
        end
    end
end