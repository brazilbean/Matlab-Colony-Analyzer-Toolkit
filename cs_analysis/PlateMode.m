%% Plate Mode - a colony size correction
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013

classdef PlateMode < Closure
    methods
        function this = PlateMode()
            this = this@Closure();
        end
        
        function fit = closure_method(this, varargin)
            fit = this.filter(varargin{:});
        end
        
        function fit = filter(~, plate)
            fit = parzen_mode(plate(:)) * ones(size(plate));
        end
    end
end