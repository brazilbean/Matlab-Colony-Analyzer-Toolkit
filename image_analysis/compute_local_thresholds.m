%% Compute Local Thresholds
% Gordon Bean, December 2012

function threshes = compute_local_thresholds( plate, grid, varargin )
    params = get_params(varargin{:});
    params = default_param( params, 'smoothing', true );
    params = default_param( params, 'thresholdFunction', ...
        @max_min_mean );
    threshes = nan(grid.dims);
        
    for rr = 1 : grid.dims(1)
        for cc = 1 : grid.dims(2)
            box = get_box( plate, grid.r(rr,cc), grid.c(rr,cc), ...
                round(grid.win/2));
            
            threshes(rr,cc) = params.thresholdfunction( box );
        end
    end
    
    if (params.smoothing)
        [~, tmp] = spatial_correction ...
            ( threshes, 'borderMethod', 'none', ...
            'spatialMethod', 'localplanar', varargin{:} );
        threshes = tmp.spatial;
    end
    
%     function it = local_threshold3( box )
%         [~, ord] = sort(box(:), 'descend');
%         it = box(ord(find( d(ord) > mean(d(ord(end-1000:end))), 1))) + 1;
%         
% %         its = min(box(:)) : max(box(:));
% %         foo = box(:);
% %         foo2 = zeros(size(its));
% %         for ii = 1 : length(its)
% %             kk = foo == its(ii);
% %             if any(kk)
% %         %         foo2(ii) = max(d(kk)) - min(d(kk));
% %         %         foo2(ii) = mean(d(kk));
% %                 foo2(ii) = median(d(kk));
% %             end
% %         end
% %         it = its( find( foo2 > 20, 1, 'last' ) ) + 5;
%     end
% 
%     function it = local_threshold2( box )
%         
%         it = nan(4,1);
%         ww = floor(size(box,1)/2);
%         foos = { 
%             sort( in(box(1:ww,1:ww)) );
%             sort( in(box(1:ww,ww+1:end)) );
%             sort( in(box(ww+1:end,1:ww)) );
%             sort( in(box(ww+1:end,ww+1:end)) );
%             };
%         
%         for jj = 1 : 4
%             foo = foos{jj};
%             foo2 = foo;
%             
%             start = 1;
% 
%             for ii = 2 : length(foo2)
%                 if (foo(ii) ~= foo(start))
%                     foo2(start:ii-1) = ...
%                         linspace( foo(start), foo(ii), ii-start );
%                     start = ii;
%                 else
%                     % Keep going
%                 end
%             end
% 
%             win = 30;
%             foog = foo2(win + 1 : end) - foo2(1 : end-win);
%             foog = [repmat(foog(1), [1 win/2]) foog' ...
%                 repmat(foog(end),[1 win/2])];
%             foog2 = foog(win + 1 : end) - foog(1 : end-win);
%             foog2 =[repmat(foog2(1),[1 win/2]) foog2 ...
%                 repmat(foog2(end),[1 win/2])];
% 
%            [~, mi] = max(foog2);
%            it(jj) = foo(mi);
%         end
%        it = median(it);
%     end
% 
%     function it = local_threshold( box )
%         m = round(size(box)/2);
%         mm = round( size(box)/4 );
%         
%         mid = false(size(box));
%         mid(m-mm:m+mm,m-mm:m+mm) = true;
% 
% %         it = ( prctile( box(:), 99.9 ) + parzen_mode(box(:)) ) / 2;
% %         it = ( max( box(:) ) + min( box(:) ) ) / 2;
%         it = ( max( box(:) ) + median( box(~mid) ) ) / 2;
%         
%         
%         if ( sum(box(mid)>it) / sum(mid(:)) ...
%                 < sum(box(~mid)>it) / sum(~mid(:)))
%             % Empty spot
%             it = max(box(:));
%         end
%     end
end