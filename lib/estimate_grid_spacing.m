%% Estimate grid spacing
% Gordon Bean, December 2012

function win = estimate_grid_spacing( plate )

    %% Estimate instensity threshold
    thresh = estimate_intensity_threshold( plate );
    
    % Use a more stringent threshold for this job.
    thresh = thresh * 1.1;
    
    %% Get middle of plate
    mids = size(plate)/2;
    mwin = size(plate)/6;

    box = plate...
        (round( mids(1) + (-mwin:mwin) ), round( mids(2) + (-mwin:mwin)));


    %% Identify spot centers
    stats = regionprops( box > thresh, 'centroid', 'area' );
    cents = cat(1, stats.Centroid);
    areas = cat(1, stats.Area );
    cents = cents( areas > 10, : );
    
    %% Compute distances
    dists = sqrt( sum( bsxfun( ...
        @minus, permute(cents, [1 3 2]), permute(cents, [3 1 2])).^2, 3) );
    dists(eye(size(dists))==1) = max(dists);

    %% Determine grid spacing parameter
    win = round( parzen_mode( min( dists ) ) );
    
end