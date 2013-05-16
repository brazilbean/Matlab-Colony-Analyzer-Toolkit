%% Min Frequency
% Gordon Bean, May 2013

classdef min_frequency < threshold_method
    methods
        function this = min_frequency
            this = this@threshold_method();
            
        end
        function it = determine_threshold(this, box)
            %% Get frequencies
            [n, x] = hist(box(:), min(box(:)):max(box(:)));

            %% Compute threshold
            pm = fastmode(box(box < mean(box(:))));
            it = min(x(n < median(n) & x > pm));

        end
    end
end