%% Determine Grid from Corners
% Gordon Bean, December 2012

function grid = determine_grid_from_corners( corners, grid )
    
    dims = grid.dims;
    [cc, rr] = meshgrid( 1 : dims(2), 1 : dims(1) );

    % Grid factors
    rrr = [1 1 dims(1) dims(1)]';
    ccc = [1 dims(2) dims(2) 1]';

    rfact = [ones(4,1) rrr ccc] \ corners(:,2);
    cfact = [ones(4,1) rrr ccc] \ corners(:,1);

    % Compute grid position
    n = numel(rr);
    grid.r = reshape([ones(n,1) rr(:) cc(:)] * rfact, dims);
    grid.c = reshape([ones(n,1) rr(:) cc(:)] * cfact, dims);

    grid.factors.row = rfact;
    grid.factors.col = cfact;

    grid.win = nanmean(diff(grid.c(1,:)));
end