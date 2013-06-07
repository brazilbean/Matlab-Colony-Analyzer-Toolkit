%% Border Median - A median border filter function
% Gordon Bean, June 2013

function out = border_median( data, varargin )

    % Determine mode of operation
    % If data is a str, assume it is a parameter, and return a function
    % handle.
    % Otherwise, apply the spatial_median spatial filter.

    if nargin == 0
        % No arguments, return the function handle
        out = @(x) border_median(x);
        
    elseif ischar(data)
        % Just arguments, no data - return the function handle
        % Check for uneven number of arguments (remember that data is part
        % of varargin)
        if mod(length(varargin),2) == 0
            error('Uneven number of parameter-value argument pairs.')
        end
        
        % Return the function handle
        out = @(x) border_median(x, data, varargin{:});

    else
        % Apply the filter
        params = default_param( varargin, ...
            'depth', 2 );
        
        % Return parameters if data is empty (special debug case)
        if isempty(data)
            out = params;
            
        else
            % Estimate median border filter
            dd = params.depth;
            out = ones(size(data));
            
            for d = 1 : dd
                % Row medians
                out([d end-d+1],d+1:end-d) = repmat ...
                    (nanmedian(data([d end-d+1],:),2),[1 size(out,2)-d*2]);

                % Column medians
                out(d+1:end-d,[d end-d+1]) = repmat ...
                    (nanmedian(data(:,[d end-d+1]),1),[size(out,1)-d*2 1]);

                % Corners
                out(d,d) = max(out(d,d+1),out(d+1,d));
                out(d,end-d+1) = max(out(d,end-d),out(d+1,end-d+1));
                out(end-d+1,end-d+1) = ...
                    max(out(end-d+1,end-d),out(end-d,end-d+1));
                out(end-d+1,d) = max(out(end-d+1,d+1),out(end-d,d));
            end
        end
        
    end
        
end