%% Estimate Orientation
% Matlab Colony Analyzer Toolkit
% Gordon Bean, December 2013
%
% Returns the orientation of the plate in RADIANS
%
% Syntax
% theta = estimate_orientation( plate, it );
% theta = estimate_orientation( plate, it, 'Name', Value, ... );
%
% Description
% THETA = estimate_orientation( PLATE, IT ) returns the angle, in radians, 
% between the rows of the colony grid and the edge of the image. PLATE is a
% matrix representing the plate image. IT is the intensity threshold used
% to determine colonies from the background. 
%
% THETA = estimate_orientation( PLATE, IT, 'Name', Value', ... ) accepts
% additional name-value pair arguments from the following list (defaults in
% <>):
%  'box' - a 2D window in the matrix PLATE used to determine the
%  orientation. If not specified, the algorithm uses a 2D window of width
%  equal to 1/4th the width of the plate positioned at the center of the
%  image. 
% 
%  'filter' < @(x) false(size(x)) > - a function handle used to remove
%  colonies from consideration by the algorithm based on their size. The
%  function handle should accept an array of colony sizes and return a
%  binary vector of the same size.
%
% 'gridSpacing' < estimate_grid_spacing(PLATE) > - a scalar indicating the
% distance, in pixels, between the centers of adjacent colonies. 
% 
% 'thresholdMethod' < MinFrequency() > - a ThresholdMethod object. If IT is
% NaN, this object is used to determine the intensity threshold used by the
% algorithm. 
%
% Algorithm
% The algorithm searches for the value of theta that creates the best
% periodicity of period 'gridSpacing' among the positions of the colonies.
% In other words, what value of theta, when used to rotate the colony
% positions, creates new colony positions that are at regular intervals and
% in phase with the coordinate axes. 

function theta = estimate_orientation( plate, it, varargin )
    params = default_param( varargin, ...
        'box', apply(fix(size(plate)/2), fix(size(plate,2)/8), ...
            @(middle, win) get_box(plate, middle(1), middle(2), win)), ...
        'filter', @(x) false(size(x)), ...
        'gridSpacing', nan, ...
        'thresholdMethod', @disjoint_component_threshold);
    
    if isnan(it)
        it = params.thresholdmethod(params.box);
        if numel(it) == 1
            binary = params.box > it;
        else
            binary = it;
        end
    end
    if isnan(params.gridspacing)
        params.gridspacing = estimate_grid_spacing(plate);
    end
    
    % Get centroid and area of spots
    [cent, area] = component_props(binary);
    
    % Find theta
    w = params.gridspacing;
    nix = params.filter(area);
    wi = area(~nix);
    ai = cent(~nix,1);
    bi = cent(~nix,2);

    % Phi is the reference point for the colony positions [ai bi]. 
    % Note that in the equation below, I use the inverse-rotation matrix,
    % which is the standard rotation matrix with negative theta. Thus, x' =
    % x*cos(theta) + y*sin(theta) and y' = -x*sin(theta) + y*cos(theta).
    align_fun = @(theta, phi) ...
        wi' * ( ...
        (1 - cos( 2*pi/w * ...
            ((ai+phi(1))*cos(theta) + (bi+phi(2))*sin(theta)))) + ...
        (1 - cos( 2*pi/w * ...
            ((bi+phi(2))*cos(theta) - (ai+phi(1))*sin(theta)))) );

    theta = -pi/4 : 0.01 : pi/4;
    foo = nan(length(wi), length(theta));

    % Search across phases of several spots, searching a range of theta's
    step = max(1,floor(length(wi)/10));
    for ci = 1 : step : length(wi)
        phi = -[ai(ci) bi(ci)];
        foo(ci,:) = align_fun(theta, phi);
    end
    
    % Pick the best fit
    [phii, thetai] = ind2sub(size(foo), argmin(foo(:)));
    
    % Search again over a finer range of theta's
    thw = 0.02;
    theta_ = theta(thetai);
    theta = linspace(theta_-thw, theta_+thw,100);
    
    phi = -[ai(phii), bi(phii)];
    foo = align_fun(theta, phi);

    % Return the best fit
    thetai = argmin(foo);
    theta = theta(thetai);

end