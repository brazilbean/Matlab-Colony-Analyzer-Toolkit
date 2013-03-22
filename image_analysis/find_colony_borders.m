%% Find colony borders
% Gordon Bean, December 2012

function mins = find_colony_borders( tmp, ithresh )
    if (nargin < 2)
        ithresh = nan;
    end
    
    midr = floor( size(tmp,1)/2 );
    midc = floor( size(tmp,2)/2 );

    w = floor(midr/3);
    
    % North
    [~,mi] = min(tmp(1:midr,midc +(-w:w)));
    rmin = median(mi);
    if (~isnan(ithresh))
        for ii = midr : -1 : rmin
            if (max( tmp(ii,midc+(-w:w)) ) < ithresh)
                rmin = ii;
                break;
            end
        end
    end
    
    % South
    [~,mi] = min(tmp(1+midr:end,midc+(-w:w)));
    rmax = median(mi) + midr;
    if (~isnan(ithresh))
        for ii = midr : rmax
            if (max( tmp(ii,midc+(-w:w)) ) < ithresh)
                rmax = ii;
                break;
            end
        end
    end
    
    % West
    [~,mi] = min(tmp(midr+(-w:w),1:midc),[],2);
    cmin = median(mi);
    if (~isnan(ithresh))
        for ii = midc : -1 : cmin
            if (max( tmp(midr+(-w:w), ii) ) < ithresh)
                cmin = ii-1;
                break;
            end
        end
    end
    
    % East
    [~,mi] = min(tmp(midr+(-w:w),1+midc:end),[],2);
    cmax = median(mi) + midr;
    if (~isnan(ithresh))
        for ii = midc : cmax
            if (max( tmp(midr+(-w:w), ii) ) < ithresh)
                cmax = ii;
                break;
            end
        end
    end
    
    mins = [rmin rmax cmin cmax];
end