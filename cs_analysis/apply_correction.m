%% Apply correction - Apply a plate correction
% Gordon Bean, June 2013
% 
% Assumes the data are arranged in an n x m grid, where n is the number of
% plates and m is the product of the grid dimensions.

function out = apply_correction( data, varargin )
    % Get dimensions
    n = size(data,2);
    dims = [8 12] .* sqrt( n / 96 );
    
    % Apply corrections
    out = data;
    for correction_ = varargin; correction = correction_{:};
        for ii = 1 : size(out,1)
            % Apply filter
            tmp = correction(reshape(out(ii,:), dims));
            
            % Correct plate
            out(ii,:) = out(ii,:) ./ tmp(:)';
        end
    end
    
end