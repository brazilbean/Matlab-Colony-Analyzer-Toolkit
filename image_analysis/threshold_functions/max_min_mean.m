%% Intensity Threshold Function: Max-Min Mean
% Gordon Bean, February 2013

function it = max_min_mean( box )

    m = round(size(box)/2);
    mm = round( size(box)/4 );

    mid = false(size(box));
    mid(m-mm:m+mm,m-mm:m+mm) = true;

%     it = ( prctile( box(:), 99.9 ) + parzen_mode(box(:)) ) / 2;
%     it = ( max( box(:) ) + min( box(:) ) ) / 2;
    it = ( max( box(:) ) + median( box(~mid) ) ) / 2;

    if ( sum(box(mid)>it) / sum(mid(:)) ...
            < sum(box(~mid)>it) / sum(~mid(:)))
        % Empty spot
        it = max(box(:));
    end

end