%% Find colony borders
% Gordon Bean, December 2012

function mins = find_colony_borders_threshed( tmp, threshed )
    if (nargin < 2)
        threshed = nan;
    end
    
    midr = floor( size(tmp,1)/2 );
    midc = floor( size(tmp,2)/2 );

    w = floor(midr/3);
    
    % North
    [~,mi] = min(tmp(1:midr,midc +(-w:w)));
    rmin = median(mi);
    if (~isnan(threshed))
        rmin_ = find(all(~threshed(midr : -1 : rmin, midc+(-w:w)),2),1);
        if (~isempty(rmin_))
            rmin = midr - rmin_ + 1;
        end
        
%         for ii = midr : -1 : rmin
%             if (max( tmp(ii,midc+(-w:w)) ) < ithresh)
%                 rmin = ii;
%                 break;
%             end
%         end
    end
    
    % South
    [~,mi] = min(tmp(1+midr:end,midc+(-w:w)));
    rmax = median(mi) + midr;
    if (~isnan(threshed))
        rmax_ = find(all(~threshed(midr:rmax,midc+(-w:w)),2),1);
        if (~isempty(rmax_))
            rmax = midr + rmax_ - 1;
        end
        
%         for ii = midr : rmax
%             if (max( tmp(ii,midc+(-w:w)) ) < ithresh)
%                 rmax = ii;
%                 break;
%             end
%         end
    end
    
    % West
    [~,mi] = min(tmp(midr+(-w:w),1:midc),[],2);
    cmin = median(mi);
    if (~isnan(threshed))
        cmin_ = find(all(~threshed(midr+(-w:w),midc:-1:cmin),1),1);
        if (~isempty(cmin_))
            cmin = midc - cmin_ + 1;
        end
%         for ii = midc : -1 : cmin
%             if (max( tmp(midr+(-w:w), ii) ) < ithresh)
%                 cmin = ii-1;
%                 break;
%             end
%         end
    end
    
    % East
    [~,mi] = min(tmp(midr+(-w:w),1+midc:end),[],2);
    cmax = median(mi) + midr;
    if (~isnan(threshed))
        cmax_ = find(all(~threshed(midr+(-w:w),midc:cmax),1),1);
        if (~isempty(cmax_))
            cmax = midc + cmax_ - 1;
        end
%         for ii = midc : cmax
%             if (max( tmp(midr+(-w:w), ii) ) < ithresh)
%                 cmax = ii;
%                 break;
%             end
%         end
    end
    
    mins = [rmin rmax cmin cmax];
end