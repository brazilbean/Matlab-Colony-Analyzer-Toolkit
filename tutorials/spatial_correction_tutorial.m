%% Tutorial - Spatial Correction Tutorial
% Matlab Colony Analyzer Toolkit
% Gordon Bean, January 2014
% gbean@ucsd.edu
%
% This tutorial will help you know how to apply spatial corrections (such
% as spatial artifacts, border effects, etc.) to the colony sizes. 

%% apply_correction
% apply_correction is the function that, well, applies colony size
% corrections. It's usage is as follows:

corrected = apply_correction( data, param_value_pairs, corrections );

% The usage will become more clear with the examples below. 

%% Spatial Corrections
% There are a number of spatial correction algorithms available. I'm not
% sure at this point which works best. Some seem to work better at 1536
% densities, while others at 6144 densities. Some work better when the data
% are relatively smooth, while others handle outliers better. I encourage
% you to try them out and find a decision that works best for you and your
% data.
%
% The general idea behind a spatial correction algorithm is to estimate the
% local background colony size so you can detect regions of the plate where
% the colonies are collectively larger or smaller than the rest of the
% plate. By dividing (or subtracting, etc.) by the background size, you can
% normalize out these artifacts.
%
% Note that one side effect of normalizing by the background colony size is
% that the median colony size of the plate will become 1. See Example 3
% below.
%

%% SpatialMedian
% The SpatialMedian algorithm computes the background as the median of the
% colony sizes in a 2D round window centered at the position. It has the
% following parameters (options in [square], defaults in {curly} braces):
%
% 'WindowSize' {9} - the radius of the 2D window
% 'WindowShape' [{'round'}, 'square'] - the shape of the 2D window. 
% 'WindowFun' {@nanmedian} - the function applied to the window to return
% the background value. 
% 'Window' - a 2D binary mask specifying the window centered at each
% position. If this is specified, 'WindowSize' and 'WindowShape' or
% ignored.
% 'AcceptZeros' {false} - When regions of the plate have many zeros, the
% median may be zero, which may result in division by zero and NaN and Inf
% values. If false, then background values of zero are replaced by the
% closest non-zero value to the median in that window. If true, nothing is
% done to correct zero-values. Note that when there are not values other
% than zero within a window, acceptZeros == false will result in NaN values
% in those positions.

%% SpatialSurface
% The SpatialSurface algorithm fits a high-order 2D polynomial to the data
% to estimate the background. Because this is essentially a regression, it
% is somewhat sensitive to outliers. If you like the polynomial fit
% algorithm, you can write your own algorithm using this as a template that
% ignores outliers. It has one parameter:
%
% 'degree' {7} - the degree of the polynomial. Higher numbers increases the
% ability to fit finer features in the data, lower numbers result in more
% smoothing.

%% Border Corrections
% BorderMedian corrects for the border artifact - the phenomenon that
% colonies on the perimeter of the plate grow larger than colonies in the
% middle of the plate. This is done using the same approach as used by
% Costanzo et al. and Collins et al.: The background is estimated as the
% median of each row and column. However, unlike in other implementations,
% I only correct the outermost rows and columns (to a specified depth). 
%
% 'depth' {4} - the number of rows and columns on the perimeter to
% correct.

%% Plate corrections
% The last correction mentioned here is a plate correction. Because of
% environmental differences from plate to plate, you want to make the
% plates comparable before performing analyses. The standard plate
% correction is to divide by the mode colony size.
%
% This correction is evoked with the PlateMode algorithm. It has no
% parameters.

corrected = apply_correction( data, PlateMode() );

%% SpatialBorderMedian - the standard spatial/border correction
% Most plates are affected by spatial and border artifacts. I have found
% that the best way to correct for these artifacts is to address them at
% the same time, rather than one then the other.
%
% SpatialBorderMedian is, therefore, the most frequent correction I use. It
% performs the spatial and border corrections together. Like many of the
% algorithms in the Colony Analyzer Toolkit, SpatialBorderMedian is a
% parameterizable function.
%
% 'SpatialFilter' {SpatialMedian()} - the algorithm used for the spatial
% correction.
% 'BorderFilter' {BorderMedian()} - the algorithm used for the border
% correction.
%
% For example, you want to use the SpatialSurface algorithm instead of the
% SpatialMedian algorithm, you would do the following:

corrected = apply_correction( data, ...
    SpatialBorderMedian('SpatialFilter', SpatialSurface()) );

% Or if you want to use a SpatialMedian algorithm with a larger window, you
% can pass a parameterized version of SpatialMedian to SpatialBorderMedian:

corrected = apply_correction( data, ...
    SpatialBorderMedian('SpatialFilter', SpatialMedian('windowSize', 13)));

% You do not need to use SpatialBorderMedian (although I recommend it). For
% example:

corrected = apply_correction( data, SpatialSurface(), SpatialBorder(), ...
    SpatialMedian('windowSize', 7, 'windowShape', 'square'));

% This code will apply (in order) the SpatialSurface, SpatialBorder, and
% SpatialMedian (with a square window of width 7*2+1) corrections. 

% Note that SpatialBorderMedian does NOT apply the PlateMode algorithm.

%% Other parameters for apply_correction
% apply_correction also accepts parameters:
%
% 'dim' {2} - the dimension along which to apply the correction. For
% example, I may have run 10 experiments with 3 replicates in 1536 format
% and store my data in a 10 x 3 x 1536 matrix. In this case, I want to
% apply the corrections along the 3rd dimension:

corrected = apply_correction( data, 'dim', 3, ...
    SpatialBorderMedian(), PlateMode() );

% 'parallel' {false} - if you have the Matlab Parallel Processing Toolbox,
% this option will execute the corrections in a parfor loop.
%
% 'function' {@rdivide} - this parameter specifies the function used to
% apply the correction. Each correction algorithm returns the background
% values. How the actual data are modified relative to these values is
% defined by this function. For raw colony sizes, @rdivide is the standard
% correction. However, for other kinds of data (such as residuals), it may
% be more appropriate to use @minus. You can pass in any function that
% accepts to arguments (the data and the background) as vectors.

%% Example 1 - standard analysis
% For a typical analysis, I would apply the SpatialBorderMedian and
% PlateMode corrections. Assuming my data are stored in a 10 x 3 x 1536 
% matrix:

corrected = apply_correction(data, 'dim', 3, ...
    SpatialBorderMedian(), PlateMode() );

%% Example 2 - parallel processing
% Assuming my data are stored in a 1000 x 3 x 1536 matrix and I want to
% apply the corrections in parallel:

corrected = apply_correction(data, 'dim', 3, 'parallel', true, ...
    SpatialBorderMedian(), PlateMode());

%% Example 3 - preserve original median size
% Sometimes you want to correct for spatial artifacts, but you don't want
% to normalize out the median size of the plate. In this case, you would
% pass in your own function:

corrected = apply_correction(data, 'dim', 3, 'parallel', true, ...
    'function', @(x, b) x ./ b .* nanmedian(x(:)), ...
    SpatialBorderMedian() );

% Here, the anonymous function divides the data by the background and then
% re-scales the data to have the original median size. 

%% Example 4 - look at the background
% You can use a correction algorithm manually. All correction algorithms
% expect a single plate in grid-dimension format (e.g. 32x48 or 64x96). 

plate = reshape(data(10,1,:), [32 48]);
SBM = SpatialBorderMedian();
background = SBM(plate);

pseudoplate(background, 'style', 'imagesc');
axis image

