%% Fast Local Intensity-fitted Method, subclass of threshold method
% Gordon Bean, May 2013

classdef fast_local_fitted_full < fast_local_fitted
    properties
        bins;
        fdr;
        num_background_iters;
        upper_threshold_function;
    end
    
    methods
        % Constructor
        function this = fast_local_fitted_full(varargin)
            % Superclass constructor
            this = this@fast_local_fitted( 'upper_threshold_function', ...
                @(box)(min(box(:))+max(box(:)))/2, varargin{:} );
            
        end
    end
end