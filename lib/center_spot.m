%% Center spot - measure the size of the center spot
% Gordon Bean, May 2013
%
% Someday, I may write this in C and make it faster...?

function [n, counted] = center_spot( box )
    if ~islogical(box)
        error('Input should be logical');
    end
    
    searchlist = nan(numel(box),1);
    visited = false(size(box));
    visited(ceil(end/2)) = true;
    searchlist(1) = find(visited);

    counted = false(size(box));

    spos = 1;
    sadd = 2;
    w = size(box,1);

    while spos < sadd
        % Get current spot
        ii = searchlist(spos);

        % Count spot
        counted(ii) = box(ii) && visited(ii);

        % Add adjacent spots
        for jj = [1 -1 w -w]
            if (box(ii+jj) && ~visited(ii+jj))
                searchlist(sadd) = ii+jj;
                sadd = sadd+1;
                visited(ii+jj) = true;
            end
        end

        % Increment (search adjacent spots)
        spos = spos + 1;
    end
    
    n = sum(counted(:));
end