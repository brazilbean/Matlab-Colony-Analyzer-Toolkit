%% Tutorial - Grid Alignment
% Gordon Bean, July 2013
%
% The purpose of this tutorial is to help you know what parameters to use
% when fitting the colony grid to the plate image. 

%% Manual Grid
% The most basic way to perform grid alignment is to use the manual
% algorithm, encoded in the ManualGrid class. In this case, the user is
% shown an image of the plate and then clicks on the image to identify the
% for corners of the grid. The grid is computed from these four corners and
% then adjusted for the optimal fit. 

% Load the plate
plate = load_plate('sample_images/1536_24hrs/1536_24hrs_0001.JPG');

% Fit the grid
manGrid = ManualGrid();
grid = manGrid( plate );

%%
% Extra detail: note the ManualGrid is an object that can be used as a
% function - in other words, ManualGrid() returns and object that is
% "callable" like a function. 
%
% You can also treat this object like an object and use one of its methods
% to fit the grid. In this case you could use either of the following
% options:
%
% grid = manGrid.fit_grid(plate);
% grid = ManualGrid().fit_grid(plate);

%% Understanding the grid
% We'll now take a moment to look at the struct returned by ManualGrid.
grid

% The "win" field indicates the distance, in pixels, between the centers of
% adjacent colonies. 
%
% "dims" denotes the row and column dimensions of the grid.
%
% "r" and "c" are matrices containing the row and column coordinates (in
% pixels) of the grid positions. For example, if grid.r(2,3) == 324.43 and
% grid.c(2,3) == 493.4, then the colony in the 2nd row, 3rd column of the
% grid is centered at 324.43 pixels from the TOP of the image and 493.4
% pixels from the left of the image. 
%
% "info" contains additional information about the grid:
grid.info

% "info.corners" is unique to manually fitted grids - it is a vector of the
% coordinates of the 4 corners you selected on the image.
% "info.theta" is the angle of orientation of the grid. 
% "info.fitfunction" is the function used to interpolate grid coordinates
% based on grid positions. See adjust_grid.m for more information on how
% this function is used.
% "info.GridFunction" is the object used to fit the grid, which in our case
% is the ManualGrid object.
% 'info.factors" is a struct containing information about the linear
% relationship between grid positions and grid coordinates. See adjust_grid
% for more information about how these are used.

%% Automatic grid fitting methods
% Manually identifying the grid for hundreds to thousands of images will
% certainly get tedious (let alone take an eternity). Thankfully, there are
% algorithms for automatically identifying the colony grid. 

grid = AutoGrid().fit_grid(plate)

% The AutoGrid algorithm determines the grid spacing (i.e. grid.win) and
% dimensions (grid.dims) from the colonies in the center of the image.
% Then, the grid is slid across all possible positions in the image and the
% optimal placement is selected. This is a simple, brute-force algorithm
% that works well on images that are very clean with clearly-defined
% colonies. 

grid = OffsetAutoGrid().fit_grid(plate)

% The OffsetAutoGrid algorithm is a little more robust than the AutoGrid
% algorithm. It similarly determines the grid spacing and dimensions from
% the center of the image. Then it fits the grid with the upper-left corner
% of the grid positioned in the center of the image, allowing the bottom
% and right portions of the grid to extend beyond the image. The overlap
% between the colonies in the image and the initial grid is computed, and
% the grid coordinates are offset to position the full grid in the correct
% location. 
%
% This algorithm works particularly better than the AutoGrid algorithm when
% the colonies are small and faint. I have found that OffsetAutoGrid tends
% to work best on most images, so I typically use it as the default.
% However, AutoGrid works on many of the images that OffsetAutoGrid fails
% to process, so I will use AutoGrid as a second try on the failed images
% before resorting to using ManualGrid.

%% Specifying the grid spacing and dimensions
% The grid spacing and dimensions can be pre-specified. This is useful when
% the grid spacing and dimension algorithms fail. When these parameters are
% known, you can provide them up front to avoid potential errors.

grid = ManualGrid('dimensions', [32 48]).fit_grid(plate)

auto = AutoGrid('dimensions', [32 48], 'gridSpacing', 71);
grid = auto(plate);

%% Other important parameters
% AutoGrid and OffsetAutoGrid have additional parameters than can be set to
% fine-tune their functionality. I have tried to provide defaults that work
% well across a variety of images, but you may find that a particular set
% of parameters works better for your images. 
%
% I recommend looking at the respective m-files for more information on
% what the parameters are and what they do. 

%% Using the grid
% To measure colony sizes, you do not need to explicitly use the grid - you
% will just specify which grid alignment algorithm to use and the real work
% will take place under the hood. However, from time to time you may find
% it useful to use the grid, such as when you want snapshots of specific
% colonies.

% When you call analyze_image or analyze_directory_of_images, the grid
% information is stored in a file called <filename>.info.mat, where
% <filename> is the name of the image file. You can load the grid struct
% using Matlab's load function, or as a second output from the load_plate
% function (again, remember that the .info.mat file must exist for this
% option to work):

[plate, grid] = load_plate('sample_images/1536_24hrs/1536_24hrs_0001.JPG');

%% Selecting a spedific colony
% You can get a 2D window around a specific colony using the get_box
% method:

row = 7;
col = 18;
box = get_box( plate, grid.r(row, col), grid.c(row, col), grid.win );
imagesc(box); axis image

% See get_box.m for more information.

%% Specifying the grid algorithm for image analysis
% You indicate which grid algorithm you want to use via the 'grid'
% parameter:

file = 'sample_images/1536_24hrs/1536_24hrs_0001.JPG';
analyze_image(file, 'grid', ManualGrid('dimensions', [32 48]));

% In this example, a ManualGrid algorithm, with pre-specified dimensions,
% will be used to analyze the sample image.




