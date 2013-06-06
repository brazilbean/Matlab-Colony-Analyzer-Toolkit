%% Interleave Filter - apply the filter to interleaved sub-grids
% Gordon Bean, June 2013

function out = interleave_filter( input, varargin )

    if isa( input, 'function_handle' )
        % Only filter was provided - return function handle
        out = @(x) interleave_filter(x, input, varargin{:});
        
    else
        % ** Interleave the filter ** %
        % Assume the input is now the data
        % Get the parameters
        params = default_param( varargin(2:end), ...
            'numSubGrids', 4, ...
            'combineFilters', false);
        
        % The nubmer of sub-grids must be a multiple of 4
        check = log(params.numsubgrids)/log(4);
        if check ~= round(check)
            error('The number of sub-grids must be a multiple of 4');
        end
        
        % Identify sub-grids
        subgrids = cell(params.numsubgrids,1);
        n = sqrt(params.numsubgrids);
        sub = 1;
        for ii = 1 : n
            for jj = 1 : n
                tmp = false(size(input));
                tmp(ii:n:end,jj:n:end) = true;
                subgrids{sub} = tmp;
                sub = sub + 1;
            end
        end
        
        % Interleave filter
        filter = varargin{1};
        out = nan(size(input));
        for ii = 1 : params.numsubgrids
            out(subgrids{ii}) = filter(input(subgrids{ii}));
        end
        
        if params.combinefilters
            % Combine the filters
            cout = nan([size(out(subgrids{1})) params.numsubgrids]);
            
            for ii = 1 : params.numsubgrids
                cout(:,:,ii) = out(subgrids{ii});
            end
            cout = nanmean(cout,3);
            for ii = 1 : params.numsubgrids
                out(subgrids{ii}) = cout;
            end
            
        end
        
    end

end