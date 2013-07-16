%% Blockfun - execute a function on a sliding block in a matrix
% Gordon Bean, May 2013
%
% FUN must be a function handle that operates on columns of a matrix.
% By default, edges of the image are padded with NaNs.

function out = blockfun( data, block, fun, varargin )
    params = default_param( varargin, ...
        'includeCenter', true, ...
        'padFunction', @nan, ...
        'positions', 1 : numel(data), ...
        'maxPosLength', 1e4, ...
        'memorySafe', numel(data) > 1e4);

    % Set up block
    if ~islogical(block)
        % Treat as dimensions of block
        block = true(block);
    end
    
    % Define neighbor indices
    sb = size(block);
    cni = repmat((1 : sb(1))' - round(sb(1)/2), [1 sb(2)]);
    rni = repmat((1 : sb(2)) - round(sb(2)/2), [sb(1) 1]);
    
    cni = cni(block);
    rni = rni(block);
        
    if ~params.includecenter
        cent = rni == 0 & cni == 0;
        rni = rni(~cent);
        cni = cni(~cent);
    end
    
    if params.memorysafe
        out = memory_safe_blockfun( data, rni, cni, fun );
    else
        out = all_at_once_blockfun( data, rni, cni, fun );
    end
    
    function out = all_at_once_blockfun( data, rni, cni, fun )
        % All at once
        out = params.padfunction(size(data));
        pos = params.positions;
        [rpos, cpos] = ind2sub(size(data), pos);

        rii = bsxfun(@plus, rpos, rni(:));
        cii = bsxfun(@plus, cpos, cni(:));
        iival = rii > 0 & rii <= size(data,1) ...
            & cii > 0 & cii <= size(data,2);
        ii = sub2ind(size(data), rii(iival), cii(iival));
        cols = params.padfunction(size(rii));
        
        cols(iival) = data(ii);

        % Execute function and reshape output
        out(pos) = fun(cols);
    end

    function out = memory_safe_blockfun( data, rni, cni, fun )
        % Iterate to avoid Out of Memory errors.
        len_pos = params.maxposlength;
        num_mem_blocks = ceil(numel(params.positions) / len_pos);
        out = params.padfunction(size(data));

        for memblock = 1 : num_mem_blocks
            % Define positions
            pos = (1 : len_pos) + (memblock-1)*len_pos;
            pos = pos(pos <= length(params.positions));
            pos = params.positions(pos);
            [rpos, cpos] = ind2sub(size(data), pos);

            % Reshape to columns
            rii = bsxfun(@plus, rpos, rni(:));
            cii = bsxfun(@plus, cpos, cni(:));
            iival = rii > 0 & rii <= size(data,1) ...
                & cii > 0 & cii <= size(data,2);
            ii = sub2ind(size(data), rii(iival), cii(iival));
            cols = params.padfunction(size(rii));

            cols(iival) = data(ii);

            % Execute function and reshape output
            out(pos) = fun(cols);
            clear cols ii iival
        end
    end
end