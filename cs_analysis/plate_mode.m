%% Mode normalize - returns the mode of a pseudo-plate
% Matlab Colony Analyzer Toolkit
% Gordon Bean, June 2013

function m = plate_mode( plate )

    if nargin == 0
        m = @(x) plate_mode(x);
    else
        m = parzen_mode(plate(:));
    end

end