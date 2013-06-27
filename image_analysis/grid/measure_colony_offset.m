%% Measure Colony Offset
% Gordon Bean, May 2013

function off = measure_colony_offset( box, varargin )
    params = default_param( varargin, ...
        'minSpotSize', 20 );
    
    % Determine window size from box dimensions
    w = (size(box,1)-1)/2;
    
    %% Determine the threshold
    % Get smaller box
    sbox = get_box(box, w+1, w+1, w/2);
    
    % Use the mean of pixel max and min intensities
    it = (median(min(box)) + max(box(:)))/2;
    sit = (median(min(sbox)) + max(sbox(:)))/2;
    it = (it + sit) / 2;
    
%     imgax(box>it);
%     input('...');
    
    %% Determine the colony location
    stats = regionprops( box > it, 'area', 'centroid');
    cents = cat(1, stats.Centroid);
    areas = cat(1, stats.Area);
    cents = cents(areas>params.minspotsize,:);
    
    % Find the colony that is closest to the center
    ii = argmin( sum(bsxfun(@minus, cents, [w+1 w+1]).^2,2) );
    
    if isempty(ii)
        off = nan; % No spots of sufficient size => empty spot
    else
        % Flip (x,y) to be (row,col)
        off = fliplr(cents(ii,:) - w - 1);
        
        % Check if an adjacent spot was found 
        if any(abs(off) > w/2)
            off = nan; % Found adjacent spot => empty spot
        end
    end
    
    %% Old stuff...
%     %% Get middle
%     mid = get_box(box, w+1, w+1, floor(w/2));
%     
%     %% Smooth
%     h = fspecial('gaussian', fix(w/6), fix(w/2)/4);
%     midsm = imfilter(mid, h, 'symmetric');
% %     midsm = imfilter(mid, h, 'circular');
% %     midsm = imfilter(mid, h, median(min(mid)));
%     
%     %% Global max
%     [a b] = ind2sub(size(midsm), argmax(midsm(:)));
%     ww = (size(mid,1)-1)/2;
%     off = [a b] - ww - 1;
%     
%     %% Climb
%     mw = params.window;
%     ww = (size(mid,1)-1)/2;
%     rpos = ww + 1;
%     cpos = ww + 1;
% 
%     going = true;
%     lims = @(ii) ii >= 1 & ii <= size(mid,1);
% 
%     while going
%         [cc, rr] = meshgrid( in(cpos+(-mw:mw),lims), ...
%             in(rpos+(-mw:mw),lims));
%         iii = in(sub2ind(size(mid),rr,cc));
%         ii = argmax( midsm(iii) ); ii = ii(1);
%         if iii(ii) == sub2ind(size(mid), rpos, cpos)
%             % At a local maximum
%             going = false;
%         else
%             % Go to the maximum
%             [rpos, cpos] = ind2sub(size(mid), iii(ii));
%             rpos = rpos(1);
%             cpos = cpos(1);
%         end
%     end
%     
%     off = [rpos, cpos] - ww - 1;
    
    
end