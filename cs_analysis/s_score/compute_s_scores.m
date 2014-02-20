function [s, svar] = compute_s_scores( data, err, array_smf )
% Computes an unaveraged S score.
%
% Data must be in query x array x repliate format.
%
% The input variable err is obtained using compute_error_estimates.
%
% array_smf must be a vector containing the single mutant fitnesses of the
% array strains.
%
% This is an updated function which replaced scoreS to allow for more
% efficient computation.
% 
% Written by Sean Collins (2006) as part of the EMAP Toolkit
% Modified by Gordon Bean (2011)

    %% Make sure array smf is 1 x n
    array_smf = array_smf(:)';
    
    %% Array stdev
    array_sd = nanmedian(nanstd(data,0,3),1);
    
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