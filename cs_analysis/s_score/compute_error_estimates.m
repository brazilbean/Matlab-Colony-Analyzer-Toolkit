%% Compute Error Estimates
% Matlab Colony Analyzer Toolkit
% Written by Sean Collins (2006) as part of the EMAP toolbox
% Modified by Gordon Bean (2011, 2012, 2014)
% 
% Computes minimum bounds for the standard error as a function of the
% unnormalized and normalized colony sizes
%
% Usage
% err = compute_error_estimates( raw, rawN, ... )
%
% Parameters
% * binSize - double scalar, default = 50
% * slideStep - double scalar, default = 10
% * smoothingWindow - double scalar, default = 21
% * minMaxSize - double scalar, default = 1300
% * spotReplicates - struct
%   The fields of this struct contain the indexes of the spot replicates
%

function err = compute_error_estimates( data, plate_sizes, varargin )
    
    %% Define parameters
    params = default_param( varargin, ...
        'numrange', 1500, ...
        'binwindow', 50/1500, ...
        'verbose', false);
    
    [nq, na, nr] = size(data);
    
    if params.verbose > 1
        % Assume the parameter is a figure handle
        figure(params.verbose);
    end
    
    %% Calculate Relative Error
    meansize = nanmean(data,3);
    error_ = bsxfun(@minus, data, meansize);
    relerr = bsxfun(@rdivide, error_, meansize);

    err.relerr = relerr;
    
    %% Calculate median size for each array mutant
    tmp_data = reshape(permute(data, [1 3 2]), [nq*nr na]);
    kans = nanmedian( tmp_data, 1);
    kans2 = repmat(kans, [nq 1 nr]);

    %% Compute error estimates as a function of the query phenotype 
    nat_range = linspace( min(plate_sizes(:)), max(plate_sizes(:)), ...
        params.numrange);
    nat2relerr = nan(size(nat_range));
    bsize = params.binwindow * max(plate_sizes(:));
    for ii = 1 : params.numrange
        list = abs(plate_sizes - nat_range(ii)) < bsize/2;
        nat2relerr(ii) = nanstd( in(relerr(repmat(list,[1,na,1]))) );
    end
    
    if params.verbose
        % Plate sizes vs relative error
        subplot(1,2,1)
        plot(nat_range, nat2relerr, 'linewidth', 3, 'color', 'k');
        pretty_figure
        labels('Plate size','Relative error');
    end
    
    %% Find weighted mean of relative errors
    % The query data will be used as a correction to the array-based 
    % estimate, so we compute the ratio of the observed relative 
    % error to the weighted mean to see if we are noisier or less 
    % noisy than average

    counts = hist( plate_sizes(:), nat_range );
    total = sum( counts(~isnan(nat2relerr)) );
    w = counts/total;
    wmean = nansum( w(:) .* nat2relerr(:) );
    nat2relerr = nat2relerr / wmean;
    
    %% Compute relative error as a function of the array phenotype 
    kan_range = linspace( min(kans2(:)), max(kans2(:)), params.numrange);
    kan2relerr = nan(size(kan_range));
    bsize = params.binwindow * max(kans2(:));
    for ii = 1 : params.numrange
        list = abs(kans2 - kan_range(ii)) < bsize/2;
        kan2relerr(ii) = nanstd( relerr(list) );
    end

    if params.verbose
        % Array size vs relative error
        subplot(1,2,2);
        plot(kan_range, kan2relerr, 'linewidth', 3, 'color', 'k');
        pretty_figure
        labels('Array size','Relative error')
    end
    
    %% Compute expected errors
    err.exp = bsxfun( @times, bsxfun(@times, ...
        interp1( nat_range, nat2relerr, plate_sizes ), ...
        interp1( kan_range, kan2relerr, kans2 )), meansize );
    
    %% Meta data
    err.info = params;
    
end % of compute_error_estimates

