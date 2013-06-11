%% Estimate Dimensions
% Gordon Bean, May 2012

function dims = estimate_dimensions( image, win )

    dims = [8 12] .* 2.^ floor( log(size(image)./[8 12] ./ win)/log(2) );

end