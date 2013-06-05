%% Spatial Median - a median-window spatial filter function
% Gordon Bean, June 2013
%
% When called without data, the function returns a function_handle to the
% parameterized function.

function out = spatial_median( data, varargin )

    %% Determine mode of operation
    % If data is a str, assume it is a parameter, and return a function
    % handle.
    % Otherwise, apply the spatial_median spatial filter.

    if nargin == 0
        % No arguments, return function handle
        out = @(x) spatial_median(x);
        
    elseif ischar(data)
        % Check for uneven number of arguments (remember that data is part
        % of varargin)
        if mod(length(varargin),2) == 0
            error('Uneven number of parameter-value argument pairs.')
        end
        
        % Return the function handle
        out = @(x) spatial_median(x, data, varargin{:});
    
    else
        % Apply the filter
        params = default_param( varargin, ...
            'windowSize', 9, ...
            'windowShape', 'round', ...
            'windowFun', @nanmedian );
        
        % Initialize the window
        if ~isfield(params, 'window')
            % No window provided, make one
            if strcmpi(params.windowshape, 'round')
                % Make a round window
                params.window = round_window( params.windowsize );
                
            elseif strcmpi(params.windowshape, 'square')
                params.window = true( params.windowsize );
                
            else
                error('Unrecognize value for WindowShape: %s', ...
                    params.windowshape);
            end
        end
    
        % Return parameters if data is empty (special debug case)
        if isempty(data)
            out = params;
            
        else
            % Compute filter
            out = blockfun ...
                (data, params.window, params.windowfun, varargin{:});
        end
        
    end
    
    function window = round_window( diam )
        window = false(diam);
        [xx, yy] = meshgrid(1:size(window,1), 1:size(window,1));
        mid = ceil(size(window,1)/2);
        r = sqrt( floor(size(window,1)/2) * size(window,1)/2 );
        window( sqrt((xx-mid).^2 + (yy-mid).^2) <= r ) = true;
    end

end