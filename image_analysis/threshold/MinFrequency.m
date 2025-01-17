%% Min Frequency - A threshold method based on pixel intensity frequencies
% MATLAB Colony Analyzer Toolkit
% Gordon Bean, May 2013
%
% Computes a pixel-intensity threshold based on the intensity with the
% minimum frequency in a 2D window around the colony. 
%
% This method is based on the observation that pixels defining the border
% between colony and background have pixel intensities that are infrequent
% compared to pixel intensities in the background and foreground.
%
% Parameters
% ------------------------------------------------------------------------
% offset < 0 >
%  - indicates the value added to the estimated pixel intensity cutoff.
%
% See also ThresholdMethod

classdef MinFrequency < ThresholdMethod
    properties
        offset;
    end
    methods
        function this = MinFrequency(varargin)
            this = this@ThresholdMethod();
            this = default_param( this, ...
                'offset', 0, varargin{:} );
        end
        function it = determine_threshold(this, box)
            %% Convert to 255-scale
            mb = max(box(:));
            rescale = false;
            if (max(box(:)) > 255)
                box = fix(box(:) ./ mb * 255);
                rescale = true;
            end
            
            %% Get frequencies
            [n, x] = hist(box(:), min(box(:)):max(box(:)));

            %% Compute threshold
            % Determine lower bound on threshold
            pm = fastmode(box(box < mean(box(:))));

            % Smooth frequency data
            ns = smooth(n,5)';

            % Compute probability of cutoff
            p1 = (max(ns)-ns) ./ (max(ns)-min(ns));
            p2 = (max(x)-x) ./ (max(x)-min(x));
%             p = p1 .* p2;
            p = p1 .* p2.^0.5;
            
            % Return most probably position
            it = in(x(x>pm), argmax(p(x>pm)));
            
            if isempty(it)
                it = nan;
            end
            
            % Re-scale to original scale
            if rescale
                it = it / 255 * mb;
            end
            
            it = it + this.offset;
            
        end
    end
end