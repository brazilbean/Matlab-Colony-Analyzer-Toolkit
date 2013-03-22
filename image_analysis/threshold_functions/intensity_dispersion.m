%% Intensity Threshold Function: Intensity Dispersion
% Gordon Bean, February 2013

function it = intensity_dispersion( box )
    w = size(box,1);
    d = sqrt(bsxfun(@plus, ((1:w)' - w/2).^2, ((1:w) - w/2).^2));
    
    [~, ord] = sort(box(:), 'descend');
    it = box(ord(find( d(ord) > mean(d(ord(end-1000:end))), 1))) + 1;

%     its = min(box(:)) : max(box(:));
%     foo = box(:);
%     foo2 = zeros(size(its));
%     for ii = 1 : length(its)
%         kk = foo == its(ii);
%         if any(kk)
%     %         foo2(ii) = max(d(kk)) - min(d(kk));
%     %         foo2(ii) = mean(d(kk));
%             foo2(ii) = median(d(kk));
%         end
%     end
%     it = its( find( foo2 > 20, 1, 'last' ) ) + 5;

end