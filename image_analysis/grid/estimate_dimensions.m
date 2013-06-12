%% Estimate Dimensions
% Matlab Colony Analyzer Toolkit
% Gordon Bean, May 2012
%
% Returns the dimensions of the grid given an image cropped to the plate
% and the grid spacing (number of pixels between adjacent colony centers).
%

function dims = estimate_dimensions( image, win )

    dims = [8 12] .* 2.^ floor( log(size(image)./[8 12] ./ win)/log(2) );

end