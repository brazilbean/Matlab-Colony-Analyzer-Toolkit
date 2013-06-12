%% Find colony borders
% Matlab Colony Analyzer Toolkit
% Gordon Bean, December 2012
%
% Returns the row and column values of the bounding box surrounding the
% colony in the center of the given 2D window.
%
% Usage
% ------------------------------------------------------------------------
% mins = find_colony_borders_threshed( tmp, threshed )
%  - TMP is the 2D window
%  - THRESHED is the thresholded version of tmp
%  - MINS is north, south, west, and east positions of the bounding box
%  (i.e. [rmin rmax cmin cmax]).
% 

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
    end
    
    % South
    [~,mi] = min(tmp(1+midr:end,midc+(-w:w)));
    rmax = median(mi) + midr;
    if (~isnan(threshed))
        rmax_ = find(all(~threshed(midr:rmax,midc+(-w:w)),2),1);
        if (~isempty(rmax_))
            rmax = midr + rmax_ - 1;
        end
    end
    
    % West
    [~,mi] = min(tmp(midr+(-w:w),1:midc),[],2);
    cmin = median(mi);
    if (~isnan(threshed))
        cmin_ = find(all(~threshed(midr+(-w:w),midc:-1:cmin),1),1);
        if (~isempty(cmin_))
            cmin = midc - cmin_ + 1;
        end
    end
    
    % East
    [~,mi] = min(tmp(midr+(-w:w),1+midc:end),[],2);
    cmax = median(mi) + midr;
    if (~isnan(threshed))
        cmax_ = find(all(~threshed(midr+(-w:w),midc:cmax),1),1);
        if (~isempty(cmax_))
            cmax = midc + cmax_ - 1;
        end
    end
    
    mins = [rmin rmax cmin cmax];
end