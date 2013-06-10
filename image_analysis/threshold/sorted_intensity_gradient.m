%% Intensity Threshold Function: Sorted-intensity gradient
% Gordon Bean, February 2013

function it = sorted_intensity_gradient( box )

    it = nan(4,1);
    ww = floor(size(box,1)/2);
    foos = { 
        sort( in(box(1:ww,1:ww)) );
        sort( in(box(1:ww,ww+1:end)) );
        sort( in(box(ww+1:end,1:ww)) );
        sort( in(box(ww+1:end,ww+1:end)) );
        };

    for jj = 1 : 4
        foo = foos{jj};
        foo2 = foo;

        start = 1;

        for ii = 2 : length(foo2)
            if (foo(ii) ~= foo(start))
                foo2(start:ii-1) = ...
                    linspace( foo(start), foo(ii), ii-start );
                start = ii;
            else
                % Keep going
            end
        end

        win = 30;
        foog = foo2(win + 1 : end) - foo2(1 : end-win);
        foog = [repmat(foog(1), [1 win/2]) foog' ...
            repmat(foog(end),[1 win/2])];
        foog2 = foog(win + 1 : end) - foog(1 : end-win);
        foog2 =[repmat(foog2(1),[1 win/2]) foog2 ...
            repmat(foog2(end),[1 win/2])];

       [~, mi] = max(foog2);
       it(jj) = foo(mi);
    end
    it = median(it);

end