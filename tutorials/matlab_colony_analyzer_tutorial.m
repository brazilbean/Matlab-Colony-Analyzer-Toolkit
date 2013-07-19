%% Matlab Colony Analyzer Tutorial
% Gordon Bean, June 2013
% gbean@ucsd.edu
%
% I suggest making a copy of this tutorial (or sections thereof) for
% analyzing you own images.
%
% This toolkit depends on the MATLAB Image Processing Toolbox and the
% Statistics Toolbox.
% If you would like to use the toolkit and do not have access to these 
% toolboxes, please email me or comment on the Github site:
%
% https://github.com/brazilbean/Matlab-Colony-Analyzer-Toolkit
%
% This toolkit is under continued expansion and development. Check back at
% the Github repository for additional features and bug fixes.
%
%
% This tutorial provides the basics for analyzing images of systematically-
% pinned microbrial plates. I recommend that you look at the accompanying
% tutorials for information on how to customize your analysis.

%% Add the toolkit to your path
addpath ./ % add the toolkit to your path

% then run
add_mca_toolkit_to_path


%% Analyze a single image
% Define which file you want to analyze
toolkitdir = '~/Downloads/Matlab-Colony-Analyzer-Toolkit-master/';
file = [toolkitdir 'sample_images/6144_12hrs/6144_12hrs_0001.JPG'];

% Analyze the image
analyze_image( file )

% This creates two extra files:
ls([file '*'])

% The .cs.txt file contains the colony size information
% The .info.mat file contains the colony grid position information

%% Look at the grid alignment and pixel intensity threshold
view_plate_image(file, 'applyThreshold', true, 'showGrid', true)

%% Load the colony sizes
colsizes = load_colony_sizes(file);
hist(colsizes(:), 50)

%% Look at a pseudo-plate image of the colony sizes
pseudoplate(colsizes)
colormap jet


%% Analyze a directory of images
% Define the directory containing the images
imagedir = 'sample_images/6144_12hrs/';

% Analyze the images
analyze_directory_of_images( imagedir )

% Note: if you have access to the MATLAB Parallel Processing Toolbox, you
% can analyze a directory of images in parallel:
%
% analyze_directory_of_images( imagedir, 'parallel', true )

%% Load the colony sizes
colsizes = load_colony_sizes( imagedir );
hist(colsizes(:), 100)
size(colsizes)

%% Look at a pseudo-plate image
pseudoplate(colsizes(1,:))
colormap jet


%% Help and useful files
help analyze_image
help analyze_directory_of_images
help measure_colony_sizes

help load plate
