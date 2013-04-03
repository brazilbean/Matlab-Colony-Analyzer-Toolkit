%% Spatial Correction
% Matlab Colony Analyzer Toolkit
% v4
% Gordon Bean, December 2011, August 2012, December 2012
%
% This correction addresses both the border and spatial artifacts. it
% expects the input data to be formated as 1 x 1536 already.
%
% Usage
% corrected = spatial_correction( plate, ... )
%
% Parameters
% * borderMethod - string = {fitted} | median | none
%   Indicates which method to use to correct the border artifact.
%   * 'fitted' fits a curve to the borders to estimate the border
%      background
%   * 'median' models the border background as the max of the row median
%      and the column median.
%
% * borderWindow - double scalar > 1, default = 8
%   Indicates the width of the window used in the fitted border correction.
%
% * spatialMethod - string = {medianwindow} | none
%   Indicates which method to use to smooth the spatial effect.
%   * 'medianwindow' uses a sliding 2D window and estimates the median of
%     the window center at each point as the background for each point. The
%     background estimation is then smoothed using a averaging image
%     filter, similar to the step used by Baryshnikova et al., Nature
%     Methods 2010, doi:10.1038/nmeth.1534
%
% * spatialWindow - double scalar > 1, default = 5
%   The radius of the 2D sliding window.
%
% * aveFiltSize - double scalar > 1, must be even, default = 10
%   The diameter of the averaging image filter described above.
%

function [corrected corrections params] = ...
    spatial_correction ( platedata, varargin )

    sz = size(platedata);
    platedata = platedata(:);
    
    %% Set up parameters
    params = get_params( varargin{:} );
    params = default_param( params, 'spatialMethod', 'medianWindow' );
    params = default_param( params, 'borderMethod', 'medianFitted' );
    params = default_param( params, 'plateDim', ...
        [8 12] * 2^(log(length(platedata)/96)/log(4)) );
    params = default_param( params, 'internalx4', false );
    
    %% Correct the given plate and return the results
    if (params.internalx4)
        pdim = params.platedim;
        params.platedim = params.platedim/2;
        tmp = false(pdim); tmp(1:2:end,1:2:end)=true; p1 = find(tmp);
        tmp = false(pdim); tmp(1:2:end,2:2:end)=true; p2 = find(tmp);
        tmp = false(pdim); tmp(2:2:end,1:2:end)=true; p3 = find(tmp);
        tmp = false(pdim); tmp(2:2:end,2:2:end)=true; p4 = find(tmp);

        noborder = ones(params.platedim);
        noborder(:,[1 2 end-1 end]) = 0;
        noborder([1 2 end-1 end],:) = 0;
        noborder = noborder(:) == 1;

        corrected = nan(sz);
        [corrected(p1) tmp3] = do_correction( platedata(p1) );
        for f = fieldnames( tmp3 )'
            corrections.(f{1}) = nan(sz);
            corrections.(f{1})(p1) = tmp3.(f{1});
        end
        [corrected(p2) tmp3] = do_correction( platedata(p2) );
        for f = fieldnames( tmp3 )'
            corrections.(f{1})(p2) = tmp3.(f{1});
        end
        [corrected(p3) tmp3] = do_correction( platedata(p3) );
        for f = fieldnames( tmp3 )'
            corrections.(f{1})(p3) = tmp3.(f{1});
        end
        [corrected(p4) tmp3] = do_correction( platedata(p4) );
        for f = fieldnames( tmp3 )'
            corrections.(f{1})(p4) = tmp3.(f{1});
        end
    
    else
        noborder = ones(params.platedim);
        noborder(:,[1 2 end-1 end]) = 0;
        noborder([1 2 end-1 end],:) = 0;
        noborder = noborder(:) == 1;

        [corrected corrections] = do_correction( platedata );
    end
    corrected = reshape( corrected, sz );
    for f = fieldnames( corrections )'
        corrections.(f{1}) = reshape( corrections.(f{1}), sz );
    end
    
%% --------------------------------------------------------------------- %%
    %% Function: Do correction
    function [plate2 corrections] = do_correction( platedata )
        corrections = struct;
        
        %% Border Corrections
        switch lower(params.bordermethod)
            case 'fitted'
                [plate2 corrections.border] = ...
                    fitted_border_correction( platedata );

            case 'median'
                [plate2 corrections.border] = ...
                    median_border_correction( platedata );

            case 'medianfitted'
                [plate2 corrections.border] = ...
                    median_fitted_correction( platedata );
                
            case 'none'
                plate2 = platedata;

            otherwise
                error('Unsupported option: %s = %s', ...
                    'bordermethod', params.bordermethod);
        end

        %% Spatial Corrections
        switch lower(params.spatialmethod)
            case 'medianwindow'
                [plate2 corrections.spatial] = ...
                    medianwindow( plate2 );

            case 'localplanar'
                [plate2 corrections.spatial] = ...
                    localplanar( plate2 );
                
            case 'localsurface'
                [plate2 corrections.spatial] = ...
                    localsurface( plate2 );
                
            case 'localmedian'
                [plate2 corrections.spatial] = ...
                    localmedian( plate2 );
                
            case 'localweighted'
                [plate2 corrections.spatial] = ...
                    localweightedsurface( plate2 );
                
            case 'borderspatial'
                [plate2 corrections.spatial] = ...
                    median_borderspatial_correction( plate2 );
                
            case 'none'
                % Yep. None.

            otherwise
                error('Unsupported option: %s = %s', ...
                    'spatialmethod', params.spatialmethod);
        end
    end

    %% Function - Local median geometric mean
    function [plate, spatial] = localmedian( pd )
        params = default_param( params, 'spatialWindow', 3 );
        win = params.spatialwindow;
        w2 = win * 2;
        
        nm = @nanmedian;
        dims = params.platedim;
        
        sz = size(pd);
        pd = reshape(pd, dims);
        
        spatial = nan(dims);
        for rr = 1 : dims(1)
            for cc = 1 : dims(2)
                r = in(max(rr-win,1):min(rr+win,dims(1)));
                c = in(max(cc-win,1):min(cc+win,dims(2)));
%                 box = pd(r, c);
                
                rm = nanmedian( pd( max(rr-win,1):min(rr+win,dims(1)), ...
                    max(cc-w2,1):min(cc+w2,dims(2)) ), 2);
                rm = rm ./ nanmedian(rm);
                cm = nanmedian( pd( max(rr-w2,1):min(rr+w2,dims(1)), ...
                    max(cc-win,1):min(cc+win,dims(2)) ), 1);
                cm = cm ./ nanmedian(cm);
%                 rm = nanmedian(box,2);
%                 cm = nanmedian(box,1);
%                 
                rfact = [ones(numel(r),1) r r.^2 r.^4] \ rm(:);
                cfact = [ones(numel(c),1) c c.^2 c.^4] \ cm(:);
                
%                 spatial(rr,cc) = sqrt( ([1 rr rr^2 rr^3] * rfact) ...
%                     * ([1 cc cc^2 cc^3] * cfact) );
                spatial(rr,cc) = ( ([1 rr rr^2 rr^4] * rfact) ...
                    + ([1 cc cc^2 cc^4] * cfact) )*nanmedian(in(pd(r,c)));
                                
            end
        end
        
        
%         spatial = nan(dims);
%         for rr = 1 : dims(1)
%             for cc = 1 : dims(2)
%                 spatial(rr,cc) = sqrt( ...
%                     nm(pd(rr,max(cc-win,1):min(cc+win,dims(2)))) * ...
%                     nm(pd(max(rr-win,1):min(rr+win,dims(1)),cc)) );
%             end
%         end
        
        plate = reshape(pd./spatial * nanmedian(pd(:)), sz);
        
    end

    %% Function - Local planar spatial correction
    function [plate, spatial] = localplanar ( platedata )
        
        params = default_param( params, 'spatialWindow', 5 );
        w = params.spatialwindow;
        
        nrow = params.platedim(1);
        ncol = params.platedim(2);
        
%         xpos = repmat(1:ncol, [nrow,1]);
%         ypos = repmat((1:nrow)', [1,ncol]);
% 
%         xneig = bsxfun(@plus, xpos(:), -w:w);
%         xneig(xneig < 1 | xneig > ncol) = nan;
%         
%         yneig = bsxfun(@plus, ypos(:), -w:w);
%         yneig(yneig < 1 | yneig > nrow) = nan;
%         
        spatial = nan(size(platedata));
        for ii = 1 : nrow*ncol
            [y, x] = ind2sub( [nrow, ncol], ii );
            [yy, xx] = meshgrid( y + (-w:w), x + (-w:w) );
            xx(xx < 1 | xx > ncol) = nan;
            yy(yy < 1 | yy > nrow) = nan;
            
            val = in(~isnan(xx) & ~isnan(yy));
            it = sub2ind( [nrow, ncol], yy(val), xx(val) );
            it = platedata(it);
            it( abs(nanzscore(it)) > 2 ) = nanmean(it);
            it( isnan(it) ) = nanmean(it);
            
            % Compute factors - X*a = I => X \ I = a
            xy = [ones(sum(val),1) xx(val) yy(val)];
            fact = xy \ it;
            
            % Compute estimation
            spatial(ii) = [1 x y] * fact;
            
        end
        plate = platedata./spatial * nanmedian(platedata);
        
    end
    
    %% Function - Local weighted surface spatial correction
    function [plate, spatial] = localweightedsurface ( platedata )
        params = default_param( params, 'spatialWindow', 3 );
        w = params.spatialwindow;
        
        params = default_param ...
            ( params, 'Afun', @(r,c) [ones(size(r)) r c r.*c r.^2 c.^2] );
        Afun = params.afun;
        
        geti = @(i,w,d) max(i-w,1):min(i+w,d);
        dims = params.platedim;
        plate = reshape(platedata, dims);
        
        spatial = nan(size(platedata));
        parfor ii = 1 : numel(spatial)
            if ( isnan(platedata(ii)) )
                continue;
            end
            [rr, cc] = ind2sub( dims, ii );
            
            b = plate(geti(rr,w,dims(1)), geti(cc,w,dims(2)));

            % Get Weights
            wt = ones(size(b));
%             wt = 1 ./ (b - nanmedian(b(:))).^2;
%             wt = 1 ./ (b - (nanmedian(b(:))+nanmean(b(:)))/2).^2;

%             rm = nanmedian(b,2);
%             cm = nanmedian(b,1);
%             wt = 1./(bsxfun(@minus,b,rm).^2 + bsxfun(@minus,b,cm).^2);
%             wt = 1./min(bsxfun(@minus,b,rm).^2,bsxfun(@minus,b,cm).^2);
%             wt =exp(-min(bsxfun(@minus,b,rm).^2,bsxfun(@minus,b,cm).^2));
            
            wt(isinf(wt)) = max(in(wt(~isinf(wt))));
            wt = wt ./ max(wt(:));

            val = ~isnan(b);
            [rg, cg] = meshgrid(geti(rr,w,dims(1)), geti(cc,w,dims(2)));
            
            X = lscov( Afun(rg(val), cg(val)), b(val), wt(val) );

            spatial(ii) = Afun(rr,cc) * X;
        
        end
        plate = platedata./spatial * nanmedian(platedata);
        
    end

    %% Function - Local 2nd order spatial correction
    function [plate, spatial] = localsurface ( platedata )
        
        params = default_param( params, 'spatialWindow', 5 );
        w = params.spatialwindow;
        
        nrow = params.platedim(1);
        ncol = params.platedim(2);
        
        spatial = nan(size(platedata));
        parfor ii = 1 : nrow*ncol
            if ( isnan(platedata(ii)) )
                continue;
            end
            [y, x] = ind2sub( [nrow, ncol], ii );
            [yy, xx] = meshgrid( y + (-w:w), x + (-w:w) );
            xx(xx < 1 | xx > ncol) = nan;
            yy(yy < 1 | yy > nrow) = nan;
            
            val = in(~isnan(xx) & ~isnan(yy));
            it = sub2ind( [nrow, ncol], yy(val), xx(val) );
            it = platedata(it);
            
            val(val) = val(val) & ~isnan(it);
            it = it( ~isnan(it) );
            
            it( abs(nanzscore(it)) > 2 ) = nanmean(it);
            it( isnan(it) ) = nanmean(it);
            
            % Compute factors - X*a = I => X \ I = a
            xy = [ones(sum(val),1) xx(val) yy(val) ...
                xx(val).^2 yy(val).^2 xx(val).*yy(val)];
            fact = xy \ it;
            
            % Compute estimation
            spatial(ii) = [1 x y x^2 y^2 x*y] * fact;
            
        end
        plate = platedata./spatial * nanmedian(platedata);
        
    end

    %% Function - Spatial Correction - median window
    function [plate spatial] = medianwindow ( platedata )
        if ( ~isfield( params, 'avefiltsize' ) )
            params.avefiltsize = 10;
        end

        if (~isfield( params, 'spatialwindow' ))
            params.spatialwindow = 3;
        end
        w = params.spatialwindow;
        
        nrow = params.platedim(1);
        ncol = params.platedim(2);
        
        %% Spatial Correction Parameters
        xpos = repmat(1:ncol, [nrow,1]);
        ypos = repmat((1:nrow)', [1,ncol]);

        xneig = bsxfun(@plus, xpos(:), -w:w);
        xneig(xneig < 1 | xneig > ncol) = nan;
        xneig2 = ...
            reshape( repmat(xneig, [1 1 2*w+1]), [nrow*ncol (2*w+1)^2] );

        yneig = bsxfun(@plus, ypos(:), -w:w);
        yneig(yneig < 1 | yneig > nrow) = nan;
        yneig2 = ...
            reshape( permute( repmat(yneig, [1 1 2*w+1]), [1 3 2]),...
            [nrow*ncol (2*w+1)^2] );

        neighbors = sub2ind( [nrow ncol], yneig2, xneig2 );

        neighcell = cell(1,nrow*ncol);
        for a = 1 : nrow*ncol
            neighcell{a} = neighbors(a,~isnan(neighbors(a,:)));
        end

        %% Correction
        plate = platedata(:);
        pmed = nanmedian( plate(noborder) );

        % Spatial Correct
        n = max(cellfun(@length, neighcell));
        tmpplate = nan(nrow*ncol, n);
        for p = 1 : size(tmpplate,1)
            tmp = plate(neighcell{p});
            tmpplate(p,1:length(tmp)) = tmp;
        end
        spatial = nanmedian(tmpplate,2);
        iii = sum(~isnan(tmpplate),2) < 3;
        
%         afilt = fspecial('average', params.avefiltsize);
%         spatial = imfilter ...
%             ( reshape(spatial, params.platedim), afilt, 'replicate');

        plate = reshape( plate(:) ./ spatial(:) * pmed, size(platedata) );
        plate(iii) = platedata(iii);
        plate( spatial == 0 ) = nan;
        spatial = reshape( spatial, size(platedata) );
        
    end

    %% Function - Median Fitted Border Correction
    function [bord fit] = median_fitted_correction( platedata )
        params = default_param( params, 'window', 4 );
        w = params.window;
        params = default_param( params, 'depth', max(6,w+2) );
        depth = params.depth;
        dims = params.platedim;
        cs = reshape( platedata, params.platedim );
        
        bord = cs;
        fit = nan(size(cs));
        
        % Corners
        for d = 1 : depth-2
            % Northwest
            pmed = nanmedian(in(cs(depth:depth*2,depth:depth*2)));
            ddr = d:depth;
            ddc = d:depth;
            dpr = d;
            dpc = d;
            tmp = [cs(ddr,dpc)' cs(dpr,ddc)];
            if (sum(~isnan(tmp)) > 2)
                tmp = nanmedian(tmp);
            
                fit(ddr,dpc) = tmp;
                fit(dpr,ddc) = tmp;

                bord(ddr,dpc) = cs(ddr,dpc) ./ tmp * pmed;
                bord(dpr,ddc) = cs(dpr,ddc) ./ tmp * pmed;
            end
            
            % Southwest
            pmed = ...
                nanmedian(in(cs(end-depth*2+1:end-depth,depth:depth*2)));
            ddr = size(cs,1)-depth+d:size(cs,1);
            ddc = d:depth;
            dpr = size(cs,1)-d+1;
            dpc = d;
            tmp = [cs(ddr,dpc)' cs(dpr,ddc)];
            if (sum(~isnan(tmp)) > 2)
                tmp = nanmedian(tmp);
            
                fit(ddr,dpc) = tmp;
                fit(dpr,ddc) = tmp;

                bord(ddr,dpc) = cs(ddr,dpc) ./ tmp * pmed;
                bord(dpr,ddc) = cs(dpr,ddc) ./ tmp * pmed;
            end
            
            % Southeast
            pmed = nanmedian(in(cs(end-depth*2+1:end-depth, ...
                end-depth*2+1:end-depth)));
            ddr = size(cs,1)-depth+1:size(cs,1)-d+1;
            ddc = size(cs,2)-depth+1:size(cs,2)-d+1;
            dpr = size(cs,1)-d+1;
            dpc = size(cs,2)-d+1;
            tmp = [cs(ddr,dpc)' cs(dpr,ddc)];
            if (sum(~isnan(tmp)) > 2)
                tmp = nanmedian(tmp);
            
                fit(ddr,dpc) = tmp;
                fit(dpr,ddc) = tmp;

                bord(ddr,dpc) = cs(ddr,dpc) ./ tmp * pmed;
                bord(dpr,ddc) = cs(dpr,ddc) ./ tmp * pmed;
            end
            
            % Northeast
            pmed = ...
                nanmedian(in(cs(depth:depth*2,end-depth*2+1:end-depth)));
            ddr = d:depth;
            ddc = size(cs,2)-depth+d:size(cs,2);
            dpr = d;
            dpc = size(cs,2)-d+1;
            tmp = [cs(ddr,dpc)' cs(dpr,ddc)];
            if (sum(~isnan(tmp)) > 2)
                tmp = nanmedian(tmp);
            
                fit(ddr,dpc) = tmp;
                fit(dpr,ddc) = tmp;

                bord(ddr,dpc) = cs(ddr,dpc) ./ tmp * pmed;
                bord(dpr,ddc) = cs(dpr,ddc) ./ tmp * pmed;
            end
            
        end
        
        % Rest of border
        for rr = 1+w:dims(1)-w
            % Get Box and Median Normalize row
            rrr = max(rr-w,1):min(rr+w,dims(1));
            dd = 1:depth;
            if (sum(~isnan(cs(rrr,dd))) > 3)
                fit(rr,dd) = nanmedian(cs(rrr,dd));
                bord(rr,dd) = cs(rr,dd) ./ fit(rr,dd) * ...
                    nanmedian(in(cs(rrr,depth:depth*2)));
            end
            dd = dims(2)-depth+1:dims(2);
            if (sum(~isnan(cs(rrr,dd))) > 3)
                fit(rr,dd) = nanmedian(cs(rrr,dd));
                bord(rr,dd) = cs(rr,dd) ./ fit(rr,dd) * ...
                    nanmedian(in(cs(rrr,end-depth*2+1:end-depth)));
            end
        end

        for cc = 1+w:dims(2)-w
            % Get Box and Median Normalize row
            ccc = max(cc-w,1):min(cc+w,dims(2));
            dd = 1:depth;
            if (sum(~isnan(cs(dd,ccc))) > 3)
                fit(dd,cc) = nanmedian(cs(dd,ccc),2);
                bord(dd,cc) = cs(dd,cc) ./ fit(dd,cc) * ...
                    nanmedian(in(cs(depth:depth*2,ccc)));
            end
            dd = dims(1)-depth+1:dims(1);
            if (sum(~isnan(cs(dd,ccc))) > 3)
                fit(dd,cc) = nanmedian(cs(dd,ccc),2);
                bord(dd,cc) = cs(dd,cc) ./ fit(dd,cc) * ...
                    nanmedian(in(cs(end-depth*2+1:end-depth,ccc)));
            end
        end
        
    end

    %% Function - Median Border Correction
    function [plate border] = median_border_correction( platedata )
        params = default_param( params, 'borderWindow', 5 );
        w = params.borderwindow;
        
        plate = reshape(platedata, params.platedim);
        
        mask = false(size(plate));
        mask([1:w end-w+1:end], :) = true;
        mask(:, [1:w end-w+1:end]) = true;

        % Correction
        pmed = nanmedian( plate(~mask) );
        
        % Border Correct
        rmeds = nanmedian(plate,2);
        cmeds = nanmedian(plate,1);
        
        border = bsxfun(@max, rmeds, cmeds) ./ pmed;
%         border(~mask) = 1;
        
        plate = plate ./ border;
        
        border = reshape( border, size(platedata) );
        plate = reshape( plate, size(platedata));

    end

    %% Function - Median Border/Spatial Correction
    function [plate border] = median_borderspatial_correction( platedata )
        params = default_param( params, 'borderWindow', 5 );
        w = params.borderwindow;
        
        plate = reshape(platedata, params.platedim);
        
        mask = false(size(plate));
        mask([1:w end-w+1:end], :) = true;
        mask(:, [1:w end-w+1:end]) = true;

        % Correction
        pmed = nanmedian( plate(~mask) );
        [~,spatial] = medianwindow( platedata );
        spatial = reshape(spatial, size(plate));
        
        % Border/Spatial Correct
        rmeds = nanmedian(plate,2);
        cmeds = nanmedian(plate,1);
        
        border = bsxfun(@max, rmeds, cmeds);
        border(~mask) = spatial(~mask);
        
        plate = plate ./ border * pmed;
        
        border = reshape( border, size(platedata) );
        plate = reshape( plate, size(platedata));

    end

    %% Function - Fitted Border Correction
    function [plate border] = fitted_border_correction( platedata )
        nr = params.platedim(1);
        nc = params.platedim(2);
        params = default_param( params, 'borderWindow', 8 );
        w = params.borderwindow;

        endr = zeros(1,nc);
        endr([1:5 end-4:end]) = 1; endr = endr == 1;
        endc = zeros(nr,1);
        endc([1:5 end-4:end]) = 1; endc = endc == 1;

        %% Apply Border Correction
        plate = reshape( platedata, params.platedim);
        [border.r border.c] = deal( nan(size(plate)) );

        for r = 1 : nr
            sr = max(1, r-w);
            er = min(nr, r+w);
            tmp = nanmean(plate(sr:er,:));
            border.r(r,endr) = tmp(endr);
            border.r(r,~endr) = nanmedian(tmp(~endr));
        end

        for c = 1 : nc
            sc = max(1, c-w);
            ec = min(nc, c+w);
            tmp = nanmean(plate(:,sc:ec),2);
            border.c(endc,c) = tmp(endc);
            border.c(~endc,c) = nanmedian(tmp(~endc));
        end

        border = reshape( max(border.c(:),border.r(:)), size(platedata));

        plate = reshape( plate(:) ./ ...
            border(:) * nanmedian(plate(noborder)), ...
            size(platedata));

    end
    
end