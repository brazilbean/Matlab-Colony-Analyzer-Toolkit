%% Tutorial: Full analysis workflow
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
% gbean@ucsd.edu
%
% This tutorial provides the basic skeleton for a genetic screen analysis.
%
% The example directories and files are not provided in the toolkit (unlike
% the examples in other tutorials); however, this tutorial is patterned
% after an actually small-scale screen conducted in our lab and should give
% you a good idea for how to perform your own analysis.
%
% I strongly recommend you read all of the tutorials before starting your
% analysis. If possible, read through the tutorials before starting the
% screen, as computational requirements may influence the structure of your
% experiments.

%% Image directory
imagedir = 'images/gal_pilots/KO_Glu+Gal_Pilot/';
files = dirfiles(imagedir, '*.JPG');

%% Mutant Labels
% Here I determine the array labels for 5 different array sets

orfs = cell(5,1536);
orfs(1,:) = in(generate_array_labels(1:16, [32 48]))';
orfs(2,:) = in(generate_array_labels(17:32, [32 48]))';
orfs(3,:) = in(generate_array_labels(33:48, [32 48]))';
orfs(4,:) = in(generate_array_labels( ...
    [49:50 70:75 101:108], [32 48]))';
orfs(5,:) = in(generate_array_labels( ...
    [109 101:107 109 101:107], [32 48]))';

% Convert ORFs to gene names
names = orf2gene(orfs);

% Condition labels - our dataset consists of plates grown in 4 conditions
conditions = {'YPAD','SC','SC+GAL','YPAD2'};

%% Define the parameters for the image analysis
% Some of these parameters are the defaults, but I include them explicitly
% to make my choices more clear.

params = { ...
    'parallel', true, ...
    'verbose', true, ...
    'grid', OffsetAutoGrid(), ... default
    'threshold', BackgroundOffset() }; % default

%% Test the parameters on a few plates
% ii = 1;
ii = 6;
tic;
analyze_image(files{ii}, params{:});
toc;

%% See how the parameters did
% If the grid is not well aligned, or the threshold looks too lenient or
% too strict, adjust the parameters above and try again.

view_plate_image(files{ii}, 'applyThreshold', true)
axis image

%% Perform the image analysis
tic;
analyze_directory_of_images( imagedir, params{:} );
toc;

%% Quality control
% Manual inspection - look at each binary image and annotate it as good or
% needing to be redone.
%
% manual_binary_inspection is one tool to help you identify images that
% were analyzed incorrectly. It iterates over each image, shows the
% thresholded version of the image, and allows the user to indicate whether
% the image was analyzed correctly. From the binary image you can determine
% whether the analysis was incorrect by noting whether there are any rows
% or columns containing half-colonies. 

out = manual_binary_inspection( imagedir );

% If you don't want to go through each binary image by hand, you can look
% at the correlation between replicates to find images that failed.
%
% Primarily, you are looking for cases where the grid was not properly
% overlaid on the image. 

%% Re-analyze failed images
failed = achar('n', out)

%%
analyze_image( files{44}, params{:}, ...
    'grid', ManualGrid('dimensions', [32 48]) );

% Note that the 'grid' option in params is overriden by the second
% occurrence (ManualGrid) of the 'grid' option. 

%% Load data
cs = load_colony_sizes( imagedir );
size(cs)

% Note that the data are loaded as matrix: num_files x num_spots

%% Quality control - plate correlation
% If you have image replicates, overall image correlation can be a quick
% and effective way of identifying failed images or problem plates.

tmp = nancorr( cs' );
imagesc(tmp); axis image;
colormap jet
colorbar

%% Average image replicates, reshape to distinguish conditions
cs = squeeze(mean(reshape(cs, [5 5 4 1536]),1));
size(cs)

% Our data are 5 image replicates x 5 array sets x 4 conditions
% We reshape the 100 images into these categories, average across the image
% replicate dimension (1), and reduce the empty dimension using squeeze.
%
% Our data are now 5 array sets x 4 conditions x 1536 spots

%% Spatial Corrections
tic;
csS = apply_correction( cs, 'dim', 3, ...
    SpatialBorderMedian(), PlateMode() );
toc;

% In our case, the 3rd dimension represents the colony size information, so
% we pass this as the 'dim' parameter.

%% Data analysis
% Here I provide an example of how we analyzed this data set

array = 1; % 1st array set
cn1 = 1; % Condition 1
cn2 = 3; % Condition 2

% Scatter the data and look for differences
% uberscat returns the Pearson and Spearman correlations, respectively
[cc ss] = uberscat( csS(array,cn1,:), csS(array,cn2,:) )
labels(conditions{cn1},conditions{cn2})
qtitle('Array %i', array)
draw_square_line
axis image

notes = scatternotes(@(x,y) y < 0.2 & x > 0.5);
% notes = scatternotes(@(x,y) y < 0.2 & x > 0.5, names(array,:));
names(array, notes)'

%% Don't forget to save your data
data.raw = cs;
data.fitness = csS;
data.orfs = orfs;
data.names = names;
data.conditions = conditions;

save images/gal_pilots/KO_Glu_Gal_Pilot/colsize_data.mat data
















