function [s, svar] = compute_s_scores( data, err, array_smf, array_sd)
% Computes an unaveraged S score.
% It takes the input variable err which is used to place a minimum 
% bound on experimental variance, the vectors cont_size (the expected
% colony sizes) and cont_sd (the estimated standard deviation for the 
% control sample).
%
% This is an updated function which replaced scoreS to allow for more
% efficient computation.
% 
% Written by Sean Collins (2006) as part of the EMAP Toolkit
% Modified by Gordon Bean (2011)

    %% Array stdev
    if nargin < 4
        array_sd = nanmedian(nanstd(data,0,3),1);
    end
    
    %% Calculate Observed N
    not_nans = ~isnan( data );
    obs_N = sum( not_nans, 3 );
    obs_N(obs_N<2) = nan;

    %% Calculate Control N
    cont_N = nanmedian(obs_N(:));
    
    %% Minimum bound on experimental SD
    err.exp(~not_nans) = 0;
    var2 = nansum( err.exp.^2, 3 ) ./ (obs_N - 1);
    var2 = max( var2, nanvar(data, 0, 3) );

    %% Minimum bound on control SD
    % cont_size * obersved median relative error for all measurements
    meansize = nanmean(data, 3);
    median_rel_error = nanmedian( in(nanstd(data,0,3) ./ meansize));
    array_sd = max( array_sd, median_rel_error * array_smf );
    
    var1 = array_sd.^2;

    %% Calculate S-score
    % Pooled Variance
    svar = bsxfun(@plus, var2 .* (obs_N - 1), var1 * (cont_N - 1)) ...
            ./ (cont_N + obs_N - 2) .* (1/cont_N + 1./obs_N);
    
    % S-score
    s = bsxfun(@minus, meansize, array_smf ) ./ sqrt( svar );

end