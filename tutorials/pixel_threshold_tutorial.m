%% Tutorial - Pixel Threshold Tutorial
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
% gbean@ucsd.edu
%
% This tutorial will help you know how to pick a pixel intensity threshold.

%% ThresholdMethod
% All pixel threshold algorithms are implemented as classes that inherit
% from ThresholdMethod. This class has two key functions:
% determine_threshold and apply_threshold; however, this class is not fully
% implemented - to do anything useful you need one of the sub-classes.

%% BackgroundOffset
% BackgroundOffset is a subcless of ThresholdMethod. It determines the
% threshold by scaling the background intensity by a fixed ammount. The
% default offset is 1.25; in other words, the default pixel threshold
% returned by BackgroundOffset is 25% brighter than the pixels surrounding
% the colonies on the plate. 

% Example:
% Load the image
plate = load_plate('sample_images/1536_24hrs/1536_24hrs_0001.JPG');

% Fit the grid
grid = OffsetAutoGrid().fit_grid(plate);

% Look at a single colony
[r, c] = deal(6, 7);
box = get_box(plate, grid.r(r,c), grid.c(r,c), grid.win);
imagesc(box); axis image;

% Compute the threshold for the specific box
thresh = BackgroundOffset().determine_threshold(box);
imagesc(box>thresh); axis image;

%% Applying the threshold to the full plate
% To apply the threshold to the full plate, use the apply_threshold method.
% Note that this method calls determine_threshold on EACH colony
% independently, rather than on the full image. 

binary_image = BackgroundOffset().apply_threshold(plate);
imagesc(binary_image); axis image;

%% Using the threshold algorithm in the image analysis
% The threshold algorithm is specified using the 'threshold' parameter:

analyze_image( file, 'threshold', BackgroundOffset() );

%% Picking an offset
% Some plates may require a different offset than others. For example,
% plates with a lighter agar may reflect the light differently and the
% default offset of 1.25 may be too bright or too dim. 
%
% Before analyzing a full collection of images, I suggest analyzing a few
% images individually and compare different offset parameters.

file = 'sample_images/1536_24hrs/1536_24hrs_0001.JPG';

% Offset is too low:
analyze_image(file, 'threshold', BackgroundOffset('offset', 1.05));
view_binary_image(file); axis image;

% Offset is too high:
analyze_image(file, 'threshold', BackgroundOffset('offset', 1.55));
view_binary_image(file); axis image;

%% Full vs sparse plates
% When the colonies are large and beginning to overgrow, the plate is
% "full." When the colonies are very small, such as just after pinning, the
% plate is "sparse." When the plate is full, the BackgroundOffset
% algorithm employs extra caution when determining the background (when the
% plate is full, the may be more bright pixels than dark pixels, making the
% background harder to identify). 
%
% Because most plates are imaged after the yeast have grown some, the
% default behavior is to assume the plate is full. If the plate is sparse,
% you can set the 'fullplate' parameter to false. This will allow the
% algorithm to run a little faster. 

analyze_image(file, 'threshold', BackgroundOffset('fullplate', false));

%% Other threshold algorithsm
% There are a number of other threshold algorithms you can look at. I 
% developed these algorithms in the process of trying to find the most 
% robust, consistent algorithm. You can learn more about each via the help
% command (or looking at their code).
%
% BackgroundOffset.m
% MinFrequency.m
% HalfModeMax.m
% LocalFitted.m
% MaxMinMean.m
