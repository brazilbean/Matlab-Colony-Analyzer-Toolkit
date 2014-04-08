%% Disjoint Component Threshold
% Matlab Colony Analyzer Toolkit
% Gordon Bean, March 2014
%
% Syntax
% binary = disjoint_component_threshold( box );
%
% Description
% binary = disjoint_component_threshold( box ) returns a binary version of
% BOX where all colony components are disjoint from one another. This
% function is useful for situations in which the colony size does not need
% to be accurate, but the colony position does. 
%
% Algorithm
% The initial intensity threshold is computed as a function of the maximum
% absolute gradient of the image at each point. 
%
% After thresholding the original image, the binary image is further
% processed to eliminate bridges connecting adjacent colonies. 

function binary = disjoint_component_threshold( box )
    % Compute the x and y gradients
    [gbox1, gbox2] = gradient(box);
    
    % Compute the maximum absolute gradient
    mag = max(abs(gbox1), abs(gbox2));

    % Compute the intensity threshold
    it = sum(box(:).*mag(:).*box(:))/sum(box(:).*mag(:));

    % Threshold original image
    binary = box > it;
    
    % Label components
    [inds, labs] = label_components(binary);

    % Find larger colonies
    area = cellfun(@length, inds);
    mode_area = parzen_mode(area);
    tmp2 = nan(size(labs));
    tmp2(labs>0) = area(labs(labs>0));

    % Enforce disjoint colonies
    tmp3 = box(tmp2>mode_area);
    it2 = (parzen_mode(tmp3)+min(tmp3))/2;
    binary = box > it2;
    
end