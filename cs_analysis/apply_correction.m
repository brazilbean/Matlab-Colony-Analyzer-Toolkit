%% Apply correction - Apply a plate correction
% Gordon Bean, June 2013
% 
% 'dim' {2} - the dimension along which to apply the corrections
% 'parallel' {false} - if true, performs the corrections in parallel using
% parfor (requires the Matlab Parallel Processing Toolbox).
% 'function' {@rdivide} - the function used to correct the data relative to
% the background colony sizes.
%
% See also spatial_correction_tutorial.m

function out = apply_correction( data, varargin )
    %% Get parameters
    ii = find( cellfun(@ischar, varargin), 1, 'last' );
    if ~isempty(ii)
        paramargs = varargin(1:ii+1);
        varargin = varargin(ii+2:end);
    else
        paramargs = {};
    end
    params = default_param( paramargs, ...
        'dim', 2, ...
        'parallel', false, ...
        'function', @rdivide);
        
    %% Get dimensions
    n = size(data, params.dim);
    dims = [8 12] .* sqrt( n / 96 );
    
    %% Apply corrections
    % Permute and reshape
%     out = shiftdim(data, params.dim-1);
    out = permute_dim(data, params.dim);
    sz = size(out);
    out = reshape(out, [sz(1) prod(sz(2:end))]);
    
    for correction_ = varargin; correction = correction_{:};
        if params.parallel
            parfor ii = 1 : size(out,2)
                % Apply filter
                tmp = correction(reshape(out(:,ii), dims));

                % Correct plate
                out(:,ii) = fil(params.function(out(:,ii),tmp(:)), @isinf);
            end
        else
            for ii = 1 : size(out,2)
                % Apply filter
                tmp = correction(reshape(out(:,ii), dims));

                % Correct plate
                out(:,ii) = fil(params.function(out(:,ii),tmp(:)), @isinf);
            end
        end
    end
    
    % Reshape and permute
    out = reshape(out, sz);
%     out = shiftdim(out, 1-params.dim);
    out = ipermute_dim(out, size(data), params.dim);
    
end