%% Threshold Bounded
% Matlab Colony Analyzer Toolkit
% Gordon Bean, March 2013
%
% Returns the area of the colony at the indicated grid position.
%
% Usage
% ------------------------------------------------------------------------
% [sz, bbox] = threshold_bounded( plate, grid, ii )
%  - PLATE is the plate image
%  - GRID is the grid struct
%  - II is the index of the colony to be quantified
%  - SZ is the area of the colony
%  - BBOX is a binary matrix of size(SZ) indicating the pixels counted as
%  part of the colony.
%

function [sz, bbox] = threshold_bounded( plate, grid, ii )
    
    box = get_box( plate, grid.r(ii), grid.c(ii), grid.win );
    
    if (islogical(grid.thresh))
        bbox = get_box( grid.thresh, grid.r(ii), grid.c(ii), grid.win );
    else
        bbox = box > grid.thresh(ii);
    end
    bounds = find_colony_borders_threshed( box, bbox );
    bbox([ 1:bounds(1) bounds(2):end],:) = false;
    bbox(:, [ 1:bounds(3) bounds(4):end]) = false;

    sz = sum(bbox(:));

end
