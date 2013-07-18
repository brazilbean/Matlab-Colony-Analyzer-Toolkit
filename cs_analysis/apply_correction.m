%% Apply correction - Apply a plate correction
% Gordon Bean, June 2013
% 
% Assumes the data are arranged in an n x m grid, where n is the number of
% plates and m is the product of the grid dimensions.

function out = apply_correction( data, varargin )
    %% Get parameters
    ii = find( cellfun(@ischar, varargin), 1, 'first' );
    if ~isempty(ii)
        params = default_param( varargin(1:ii+1), ...
            'dim', 2);
        varargin = varargin(ii+2:end);
    end
    
    %% Get dimensions
    n = size(data,params.dim);
    dims = [8 12] .* sqrt( n / 96 );
    
    %% Apply corrections
    out = data;
    
    % Permute and reshape
    out = permute_dim(out, params.dim);
    sz = size(out);
    out = reshape(out, [sz(1) prod(sz(2:end))]);
    
    for correction_ = varargin; correction = correction_{:};
        for ii = 1 : size(out,2)
            % Apply filter
            tmp = correction(reshape(out(:,ii), dims));
            
            % Correct plate
            out(:,ii) = out(:,ii) ./ tmp(:);
        end
    end
    
    % Reshape and permute
    out = reshape(out, sz);
    out = ipermute_dim(out, params.dim);
    
end