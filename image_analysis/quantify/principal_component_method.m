%% Principal Componant Colony Size Method
% Gordon Bean, February 2013

function [cs, b] = principal_component_method( box, thresh, shrink )
    if (nargin < 3)
        shrink = true;
    end
    
    % Zoom in
    if (shrink)
        w = round((size(box,1) - 1)/4);
        box = box(w+1:end-w,w+1:end-w);
    end
    
    w = size(box,1);
    d = sqrt(bsxfun(@plus, ((1:w)' - w/2).^2, ((1:w) - w/2).^2));

    if (sum(box(d<10) > thresh) < 20 && ...
            mean(box(d<5)) < mean(box(d>15)) + 5)
        % Empty Spot
        cs = 0;
        b = false(size(box));
        return;
    end
    
%     foo1 = [d(:), box(:)]; foo1 = bsxfun(@minus, foo1, mean(foo1));
%     [V,~] = eig( foo1' * foo1 );
%     foo1p = foo1 * V(:,2);
    foo1p = box(:);
    
    pm = parzen_mode(foo1p(box < thresh));
    tmp = foo1p( foo1p < pm );
    mn = min( in( fil(foo1p, foo1p < -2*std([tmp; -tmp]), inf) ) );
    b = reshape( foo1p > pm + pm - mn, size(box) );
%     b = reshape( foo1p > pm - mn, size(box) );
    
    stats = regionprops( b, 'area' );
    cs = max( cat(1, stats.Area) );
    if (isempty(cs))
        cs = nan;
    end
end