%% Estimate Orientation
% Matlab Colony Analyzer Toolkit
% Gordon Bean, December 2013
%
% Returns the orientation of the plate in RADIANS

function theta = estimate_orientation( plate, it, varargin )
    params = default_param( varargin, ...
        'box', apply(fix(size(plate)/2), fix(size(plate,2)/8), ...
            @(middle, win) get_box(plate, middle(1), middle(2), win)), ...
        'filter', @(x) false(size(x)), ...
        'gridSpacing', estimate_grid_spacing(plate) );
    
    if isnan(it)
        it = MaxMinMean().determine_threshold(params.box);
    end
    
    % Get centroid and area of spots
    [cent, area] = component_props(params.box > it);
    
    % Find theta
    w = params.gridspacing;
    nix = params.filter(area);
    wi = area(~nix);
    ai = cent(~nix,1);
    bi = cent(~nix,2);

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