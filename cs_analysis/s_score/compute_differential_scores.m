%% Compute Differential Scores
% DEMAP Toolkit
% Gordon Bean, January 2012, August 2012, February 2014
%
% Computes the differential scores.
%
% Usage
% [scores rawD] = compute_differential_scores( rawR, rawC, ... )
%
% Expects 'rawR', the reference data struct (i.e. the untreated condition),
% and 'rawC', the condition data struct (i.e. the treatment condition).
%
% Returns 'scores', a matrix containing the differential scores, and
% 'rawD', a struct containing the differential residuals, etc.
%
% Parameters
% * varMethod - string = {observed} | expErrBound | magnitudeCorrection |
%                        expErrPrior | observedBounded | none
%   The method used to compute the variance of the difference of static
%   residuals.
% 
% * smfNormFun - function handle = {@minus} | @rdivide
%   The function used to normalize out the single mutant fitness signal in
%   the plate-normalized colony sizes.
%
% * smfCalcFun - function handle = {@nanmedian} | @parzen_mode
%   The function used to estimate the single mutant fitness from the
%   plate-normalized colony sizes.
% 
% * pooledVariance - logical scalar = {1} | 0
%   Flag indicating whether the t-statistic will be calculated using a
%   pooled variance of the double mutant variance and the array mutant
%   variance.
%   

function [scores rawD params] = compute_differential_scores ...
    ( raw1, raw2, varargin )
    params = get_params( varargin{:} );
    params = default_param( params, 'varMethod', 'observed' );
    params = default_param( params, 'varBound', @(x)prctile(x,1));
    params = default_param( params, 'smfNormFun', @minus );
    params = default_param( params, 'smfCalcFun', @nanmedian );
    params = default_param( params, 'doPooledVariance', true );
    
    rawD.info = params;
    
    %% Compute Differentials
    rawD.size = raw2 - raw1;
    
    [nq, na, nr] = size( rawD.size );
    tmp = reshape( permute( rawD.size, [1 3 2]), [nq*nr na]);
    exp_colony_size = params.smfcalcfun(tmp,1);
    
    rawD.residuals = bsxfun( params.smfnormfun, rawD.size, ...
        exp_colony_size );
    
    obs_N = sum( ~isnan( rawD.size ), 3);
    obs_N(obs_N<2) = nan;

    cont_N = nanmedian(obs_N(:));

    %% Compute Variance
    switch lower(params.varmethod)
        case {'experrbound', 'magnitudecorrection'}
            % Expected Error Lower Bound
            if (~isfield( params, 'experr' ))
                error('You must provide ''experr''');
            end
            
            % Calculate Variance
            expvarR = nansum(params.experr(1).exp.^2,3);
            expvarC = nansum(params.experr(2).exp.^2,3);
            
            var2 = max ...
                ( (expvarR + expvarC)./(obs_N-1), nanvar(rawD.size,0,3) );
            
        case 'experrprior' % Expected Error Bayesian Prior
            if (~isfield( params, 'experr' ))
                error('You must provide ''experr''');
            end

            expvarR = nansum(params.experr(1).exp.^2,3);
            expvarC = nansum(params.experr(2).exp.^2,3);
            
            sc2 = ( expvarR + expvarC );
            dc = sum(~isnan(rawD.size),3) - 1;
            sc2 = sc2 ./ dc;
            
            var2 = (dc.*sc2 + (obs_N - 1).*nanvar(rawD.size, 0, 3)) ...
                ./ (dc + obs_N - 1);
                        
        case 'observed'
            var2 = nanvar( rawD.size, 0, 3);
            
        case 'observedbounded'
            tvar = nanvar( rawD.size, 0, 3);
            var2 = max( tvar , params.varbound(tvar(:)) );
            var2(var2==0) = nan;
            
        case 'none'
            var2 = ones(size(rawD.size,1), size(rawD.size,2));
            var2(var2==0) = nan;
            
        otherwise
            error('This method is not supported: %s', params.method);
        
    end
    
    if (strcmpi(params.varmethod, 'magnitudecorrection'))
        % Increase the variance for large static interactions
        
        % Compute Static Residuals
        tmp = reshape(permute(raw1,[1 3 2]),[nq*nr na]);
        mags.R = bsxfun(@minus, raw1, nanmedian(tmp,1));
        
        tmp = reshape(permute(raw2,[1 3 2]),[nq*nr na]);
        mags.C = bsxfun(@minus, raw2, nanmedian(tmp,1));
        
        mags.add = nanmean(abs(mags.R) + abs(mags.C),3);
        
        % Fit Variance
        centers = linspace( 0, prctile( mags.add(:), 100), 30);
        w = centers(2)-centers(1);
        vars = nan(length(centers),1);
        for ii = 1 : length(centers)
            list = abs( mags.add - centers(ii) ) < w;
            vars(ii) = nanmedian( sqrt(var2(list)) );
        end
        [~,eii] = min( abs(centers - prctile(mags.add(:),99.95)) );
        vars(eii:end) = vars(eii);
        
        % Calculate adjusted variances
        var2 = (sqrt(var2) ...
            ./ interp1( centers, smooth(vars), mags.add )).^2;
        
    end
    
    %% Compute Scores
    if ( params.dopooledvariance )
        rawD.meansize = nanmean(rawD.size,3);
        median_rel_error = ...
        nanmedian( in(nanstd(rawD.size,0,3) ./ rawD.meansize));
        cont_sd = max ...
            ( nanmedian(nanstd(rawD.size,0,3),1), ...
            median_rel_error * exp_colony_size );

        var1 = cont_sd.^2;

        svar = bsxfun ...
            (@plus, var2 .* (obs_N - 1), var1 * (cont_N - 1)) ...
            ./ (cont_N + obs_N - 2) .* (1/cont_N + 1./obs_N);
    else
        svar = var2;
    end
    
    scores = nanmean(rawD.residuals, 3) ./ sqrt( svar );
    
end