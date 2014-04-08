%% Estimate grid spacing
% Matlab Colony Analyzer Toolkit
% Gordon Bean, December 2012
%
% Estimate the grid spacing from an plate image
%

% Future improvements(?) under construction. Hard hats recommended. 

function win = estimate_grid_spacing( plate, varargin )

    params = default_param( varargin, ...
        'box', apply(fix(size(plate)/2), fix(size(plate,2)/8), ...
            @(middle, win) get_box(plate, middle(1), middle(2), win)), ...
        ...'filter', @(x) false(size(x)), ...
        'filter', @(x) x < 5, ...
        ...'threshold', MinFrequency());
        'threshold', @disjoint_component_threshold);
    
    if isa(params.threshold, 'function_handle') ...
            || isa(params.threshold, 'ThresholdMethod')
        params.threshold = ...
            params.threshold(params.box);
        if numel(params.threshold) == 1
            params.threshold = params.box > params.threshold;
        end
    end
    
    %% Get centroid and area of spots
    [cent, area] = component_props(params.threshold);
    
    %% Filter really small spots (if filter function is provided)
    cent(params.filter(area),:) = [];
    
    %% Compute distances
    dd = sqrt(sum(bsxfun(@minus, permute(cent, [1 3 2]), ...
        permute(cent, [3 1 2])).^2,3));
    
    %% Sort
    dds = sort(dd);
    
    %% Find distance of neighbors
    win = parzen_mode(in(dds(1:4,:)));
    
%     %% Get a robust, approximate estimate
%     win = robust_estimate( plate );
%     
    %% Fine tune
%     [cpx, rpx] = meshgrid(size(plate,2) * linspace(0.3, 0.7, 20), ...
%         size(plate,1) * linspace(0.3, 0.7, 20) );
%     wins = nan(length(rpx),1);
%     for jj = 1 : length(wins)
%         box = get_box( plate, rpx(jj), cpx(jj), 2*win );
%         wins(jj) = win_from_box( box, win );
%     end
%     win = nanmean(wins);
    
    %% Functions
    function win = robust_estimate( plate )
        %% Plate middle
        pw = floor(size(plate,1) / 20);
        pmids = floor(size(plate) / 2);
        mid = plate(pmids(1)-pw:pmids(1)+pw, pmids(2)-pw:pmids(2)+pw);

        %% Compute pixel distances
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
%         pks = pks(scales > 0.8); % Changed to 0.5 on May 17, 2013.
        pks2 = pks(scales > 0.5);

        if isempty(pks2)
            % The peak is not very tall, lower the threshold.
            pks2 = pks(scales > 0.4);
        end
        
        pks = pks2;
        win = mean(pks ./ (1:length(pks))');

    end

    function win = win_from_box( box, win )
        %% Estimate instensity threshold
%         thresh = estimate_intensity_threshold( box );

        % Use a more stringent threshold for this job.
%         thresh = thresh * 1.1;

%         thresh = fast_local_fitted('fdr', 0.01).determine_threshold(box);
        
        thresh = (median(min(box)) + median(max(box)))/2;
        
        %% Identify spot centers
        [cents, areas] = component_props(box > thresh);
        cents = cents( areas > 10, : );

        %% Compute distances
        dists = sqrt( sum( bsxfun( @minus, ...
            permute(cents, [1 3 2]), permute(cents, [3 1 2])).^2, 3) );
        dists(eye(size(dists))==1) = max(dists);
        dists(dists > 1.35*win) = nan;
        
        %% Determine grid spacing parameter
%         win = round( parzen_mode( min( dists ) ) );
        win = nanmean( dists(:) );
        
    end
end