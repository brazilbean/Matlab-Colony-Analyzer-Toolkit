%% Get 96-well format plate indexes
% Gordon Bean, March 2012

function mat = get_96_format_indexes( platedims )

    %% Calculate 96-well position matrix
    base = 1;
    while (numel(base) < prod(platedims)/96 )
    
        bmax = max(base(:));

        base2 = nan(size(base)*2);
        base2(1:2:end,1:2:end) = base+bmax*0;
        base2(1:2:end,2:2:end) = base+bmax*1;
        base2(2:2:end,1:2:end) = base+bmax*2;
        base2(2:2:end,2:2:end) = base+bmax*3;

        base = base2;

    end
    
    %% Calculate positions within 96-wells
    sz = platedims;
    rows = repmat(in(repmat((1 : 8), [sz(1)/8 1])), [1, sz(2)]);
    cols = repmat(in(repmat((1 : 12), [sz(2)/12 1]))', [sz(1), 1]);

    %% Return
    mat = cat(3, repmat(base, platedims./(size(base,1))), rows, cols);


end
