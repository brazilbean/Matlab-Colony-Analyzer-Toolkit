%% Subgrids - return the indices of the interleaved subgrids of a plate
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013
%
% Subgrids are number in column-major order, i.e (1,1), (1,2), (2,1), (2,2)
%

function subs = subgrids( size, numgrids )

    if (nargin < 2)
        numgrids = 4;
    end
    
    tmp = false( size );
    step = sqrt(numgrids);
    tmp(1:step:end,1:step:end) = true;
    tmp = find(tmp);
    ftmp = false( size );
    pos = 1;
    subs = nan(numel(tmp), numgrids);
    for row = 1 : sqrt(numgrids)
        for col = 1 : sqrt(numgrids)
            subs(:,pos) = ...
                find(fil(ftmp, tmp+(row-1)+(col-1)*size(1), true));
            pos = pos + 1;
        end
    end
end