%% Empty Spot Filter - return NaN for spots that are empty
% Matlab Colony Analyzer Toolkit
% Gordon Bean, September 2013

classdef EmptySpotFilter < Closure
    properties
        threshold
    end
    methods
        function this = EmptySpotFilter(varargin)
            this = this@Closure();
            this = default_param(this, ...
                'threshold', 20, varargin{:});
        end
        function fit = closure_method(this, varargin)
            fit = this.filter(varargin{:});
        end
        function fit = filter(this, plate)
            fit = fil(ones(size(plate)), plate < this.threshold, nan);
        end
    end
end