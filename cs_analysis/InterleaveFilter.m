%% Interleave Filter - apply the filter to interleaved sub-grids
% Gordon Bean, July 2013

classdef InterleaveFilter < Closure
    properties
        filter_ % The filter method being interleaved
        numsubgrids
        independent
    end
    
    methods
        function this = InterleaveFilter( filter_, varargin )
            this = this@Closure();
            this.filter_ = filter_;
            this = default_param( this, ...
                'numSubGrids', 4, ...
                'independent', true, ...
                varargin{:} );
            
            % The nubmer of sub-grids must be a multiple of 4
            check = log(this.numsubgrids)/log(4);
            if check ~= round(check)
                error('The number of sub-grids must be a multiple of 4');
            end
            
        end
        
        function out = closure_method(this, varargin)
            out = this.filter(varargin{:});
        end
        
        function out = filter(this, input)
            % Identify sub-grids
            sgrids = subgrids(size(input), this.numsubgrids);
            sgrids = reshape(sgrids, ...
                [size(input)/sqrt(this.numsubgrids) this.numsubgrids]);
            
            % Interleave filter
            out = nan(size(input));
            for ii = 1 : this.numsubgrids
                out(sgrids(:,:,ii)) = this.filter_(input(sgrids(:,:,ii)));
            end
            
            % Preserve subgrid means
            if ~this.independent
                cout = nanmean(out(sgrids),3);
                
                for ii = 1 : this.numsubgrids
                    out(sgrids(:,:,ii)) = cout;
                end
            end
        end
    end
end
