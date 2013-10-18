%% CorrectedMixture - a colony threshold algorithm
% Matlab Colony Analyzer Toolkit
% Gordon Bean, October 2013
%
% Corrects the background intensity of the plate, then computes the
% threshold using a Gaussian mixture model.
%
% Requires the Matlab Statistics Toolbox.

classdef CorrectedMixture < ThresholdMethod
    properties
        window;
        sig2noise;
        positions;
    end
    
    methods
        function this = CorrectedMixture( varargin )
            this = this@ThresholdMethod();
            this = default_param(this, ...
                'window', nan, ...
                'sig2noise', 1, ...
                'positions', [], varargin{:} );
        end
        
        function it = apply_threshold(this, plate, grid)
            % Determine colony region
            rmin = round(min(grid.r(:))-2*grid.win);
            rmax = round(max(grid.r(:))+2*grid.win);
            cmin = round(min(grid.c(:))-2*grid.win);
            cmax = round(max(grid.c(:))+2*grid.win);
            box = plate(rmin:rmax, cmin:cmax);
            
            % Determine preliminary threshold
            [cbox, cut, gmd] = this.preliminary_threshold(box, grid);
            bplate = false(size(plate));
            bplate(rmin:rmax, cmin:cmax) = cbox > cut;
            
            % Determine probabilities
            si = argmax(gmd.mu);
            tmp = normcdf(cbox, gmd.mu(si), sqrt(gmd.Sigma(si)));
            prob_int = zeros(size(plate));
            prob_int(rmin:rmax, cmin:cmax) = tmp;
            
            % Smooth probabilities
            sz = (2*fix(grid.win/6)+1) * [1 1];
            sig = fix(sz(1)/2);
            h = fspecial('gaussian', sz, sig);
            smoothprob = imfilter( prob_int, h, 'replicate', 'same');
            
            % Mixture model
            pcut = this.gauss_cut(smoothprob(:), 1);
            
            it = bplate & smoothprob > pcut;
        end
        
        function [normplate, cut, gmd] = preliminary_threshold ...
                (this, box, grid)
            % Compute median filter
            if isnan(this.window)
                w = 2*fix(grid.win/6)+1;
            else
                w = this.window;
            end
            m = size(box,1);
            ni = bsxfun(@plus, (-w : w)', m*(-w : w));
            [cc rr] = meshgrid(-w:w, -w:w);
            ni = ni(sqrt(cc.^2 + rr.^2)<w);
            posfun = @(ii) bsxfun(@plus, ii(:), ni(:)');

            posget = @(box, pos) apply(posfun(pos), @(pos) ...
                apply(pos > 0 & pos <= numel(box), @(val) ...
                apply( box(fil(pos,~val,1)), @(ibox) ...
                fil(ibox, ~val) )));
            
            % Define positions 
            if isempty(this.positions)
                [cc rr] = meshgrid(1:size(box,2), 1:size(box,1));
                pw = fix(grid.win/4);
                pos = find((mod(rr,pw)==1 | rr==max(rr(:))) ...
                    & (mod(cc,pw)==1 | cc==max(cc(:))));
            else
                pos = this.positions;
            end
            
            % Compute medians, interpolate
            gbox = box;
            s2n = this.sig2noise;
            for iter = 1 : length(s2n)
                mbox = nanmedian(posget(gbox, pos),2);
            %     mbox = parzen_mode(posget(gbox, pos),2);
                mbox = apply(unique(cc(pos)), unique(rr(pos)), @(c, r) ...
                    interp2(c, r, reshape(mbox, [length(r) length(c)]), ...
                    cc, rr,'spline'));

                % Correct background
                cbox = box./mbox * nanmedian(mbox(:)); 

                % Fit gaussian mixture
                [cut, gmd] = this.gauss_cut(cbox(:), s2n(iter));

                % Mask box, repeat
                gbox = fil(box, cbox > cut);
            end
            normplate = cbox;

        end
        
        function [cut, gmd] = gauss_cut(~, box, sig2noise)
            % Fit mixture model
            gmd = gmdistribution.fit(notnan(box(:)), 2);
            si = argmax(gmd.mu);
            ni = setdiff([1 2], si);
            
            % Compute null and signal distributions
            xx = linspace(min(box(:)), max(box(:)), 1000);
            signal = normpdf(xx, gmd.mu(si), sqrt(gmd.Sigma(si))) ...
                .* gmd.PComponents(si);
            null = normpdf(xx, gmd.mu(ni), sqrt(gmd.Sigma(ni))) ...
                .* gmd.PComponents(ni);
            
            % Return cutoff
            cut = xx(find( signal > null*sig2noise & xx > gmd.mu(ni), 1 ));
        end
    end
    
end