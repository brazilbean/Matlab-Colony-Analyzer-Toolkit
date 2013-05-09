%% Estimate grid spacing
% Gordon Bean, December 2012

function win = estimate_grid_spacing( plate )

    %% Get a robust, approximate estimate
    win = robust_estimate( plate );
    
    %% Fine tune
    rpx = size(plate,1) * [0.4 0.4 0.5 0.6 0.6];
    cpx = size(plate,2) * [0.4 0.6 0.5 0.4 0.6];
    wins = nan(length(rpx),1);
    for jj = 1 : length(wins)
        box = get_box( plate, rpx(jj), cpx(jj), 2*win );
        wins(jj) = win_from_box( box, win );
    end
    win = nanmean(wins);
    
    %% Functions
    function win = robust_estimate( plate )
        %% Plate middle
        pw = floor(size(plate,1) / 20);
        pmids = floor(size(plate) / 2);
        mid = plate(pmids(1)-pw:pmids(1)+pw, pmids(2)-pw:pmids(2)+pw);

        %% Compute weighted pixel distances
        foo = mean(mid);
        xx = 1 : length(foo);
        foo2 = bsxfun(@minus, xx, xx');
        foo3 = bsxfun(@min, foo, foo');
        top = @(x) triu(true(size(x)),1);

        foo2 = in(foo2,top);
        foo3 = in(foo3,top);

        %% Smooth distance vs weight curve
        w = 10;
        foomax = nan(size(mid,1),1);
        for ii = 1 : length(foomax)
            list = abs(foo2 - ii) < w;
            foomax(ii) = mean(foo3(list));
        end

        %% Find peaks
        going_down = true;
        pks = nan(size(foomax));
        scales = nan(size(foomax));
        ppos = 1;
        for ii = 2 : length(foomax)
            if going_down
                if foomax(ii) > foomax(ii-1)
                    % Minimum
                    going_down = false;
                else
                    % still going down
                end
            else % going up
                if foomax(ii) > foomax(ii-1)
                    % still going up
                else
                    % maximum
                    going_down = true;
                    pks(ppos) = ii;
                    tmp = min(foomax(1:ii));
                    scales(ppos) = foomax(ii) - tmp;
                    scales(ppos) = scales(ppos) ...
                        / (max(foomax(1:ii))-tmp);
                    ppos = ppos + 1;
                end
            end
        end
        pks = pks(1:ppos-1);
        scales = scales(1:ppos-1);
        pks = pks(scales > 0.8);

        win = floor(mean(pks ./ (1:length(pks))'));

    end

    function win = win_from_box( box, win )
        %% Estimate instensity threshold
        thresh = estimate_intensity_threshold( box );

        % Use a more stringent threshold for this job.
        thresh = thresh * 1.1;

        %% Identify spot centers
        stats = regionprops( box > thresh, 'centroid', 'area' );
        cents = cat(1, stats.Centroid);
        areas = cat(1, stats.Area );
        cents = cents( areas > 10, : );

        %% Compute distances
        dists = sqrt( sum( bsxfun( @minus, ...
            permute(cents, [1 3 2]), permute(cents, [3 1 2])).^2, 3) );
        dists(eye(size(dists))==1) = max(dists);
        dists(dists > 1.3*win) = nan;
        
        %% Determine grid spacing parameter
%         win = round( parzen_mode( min( dists ) ) );
        win = nanmean( dists(:) );
        
    end
end