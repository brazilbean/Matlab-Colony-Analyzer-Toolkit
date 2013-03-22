%% Local Intensity-fitted Method
% Gordon Bean, February 2013

function [cs, bth, its] = local_intensity_fitted_method ...
    ( plate, grid, varargin )
    
    params = get_params( varargin{:} );
    params = default_param( params, 'pthresh', 4.5);
    PTHRESH = params.pthresh;
    params = default_param( params, 'mode', 'plate' );
    
    switch lower(params.mode)
        case 'plate'
            bigwin = grid.win;
            if (prod(grid.dims)==6144)
                bigwin = grid.win*2;
            elseif (prod(grid.dims)==24576)
                bigwin = grid.win*4;
            end

            bth = false(size(plate));
            [cs, its] = deal( nan(grid.dims) );
    
            % Iterate over spots
            for rr = 1 : grid.dims(1)
                for cc = 1 : grid.dims(2)
                    % Get big box, fit distribution
                    bxb = get_box ...
                        (plate, grid.r(rr,cc), grid.c(rr,cc), bigwin);
                    [bpm, st] = get_pm_std( bxb );

                    % Get small box
                    bx = get_box ...
                        ( plate, grid.r(rr,cc), grid.c(rr,cc), grid.win );
                    bo = find_colony_borders( bx );
                    b = bx(bo(1) : bo(2), bo(3) : bo(4));

                    % Compute p-values
                    pvals = get_pvals( b, bpm, st );

                    % Threshold
                    bb = false(size(bx));
                    bb(bo(1) : bo(2),bo(3) : bo(4)) = pvals > PTHRESH;
                    bth = set_box( bth, bb, grid.r(rr,cc), grid.c(rr,cc) );

                    % Measure size
                    cs(rr,cc) = get_size(pvals>PTHRESH); 
                    
                    % Save threshold
                    if (nargout > 2)
                        its(rr,cc) = max(b(pvals < PTHRESH));
                    end

                end
            end
            
        case 'box'
            % Assume plate is big box
            [bpm, st] = get_pm_std( plate );
            w = round((size(plate,1)-1)/4);
            
            % Small box
            bx = plate(w+1:3*w+1,w+1:3*w+1);
            bo = find_colony_borders( bx );
            b = bx(bo(1) : bo(2), bo(3) : bo(4));
            
            % Compute p-values
            pvals = get_pvals( b, bpm, st );

            % Threshold
            bb = false(size(bx));
            bb(bo(1) : bo(2),bo(3) : bo(4)) = pvals > PTHRESH;
            bth = false(size(plate));
            bth(w+1:3*w+1,w+1:3*w+1) = bb;

            % Measure size
            cs = get_size(pvals(:)>PTHRESH);
            
            its = max(b(pvals < PTHRESH));

        otherwise
            error('Unsupported option: %s', params.mode);
    end
    function [pm, st] = get_pm_std( box )
        it = (max(box(:)) + min(box(:)))/2;
        pm = parzen_mode(box(:));
        c = 5;
        while (c > 0 && pm > it)
            it = (it + min(box(:)))/2;
            pm = parzen_mode(box(box<it));
            c = c - 1;
        end
        tmp = box(box<pm)-pm;
        st = std([tmp;-tmp]);
    end

    function pv = get_pvals( b, bpm, st )
        pv = -log( 1 - normcdf( b-bpm, 0, st ) )./log(10);
    end

    function sz = get_size( b )
        foo = regionprops(b,'area'); 
        foo = cat(1, foo.Area);
        if (isempty(foo))
            sz = 0;
        else
            sz = max(foo);
        end
    end
end