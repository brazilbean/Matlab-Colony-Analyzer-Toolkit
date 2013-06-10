%% Make Plate Threshold
% Gordon Bean, December 2012

function pt = make_plate_threshold( plate, grid )

    if (numel(grid.thresh)==1)
        grid.thresh = zeros(grid.dims) + grid.thresh;
    end
    pt = nan( size(plate) );
    
    for rr = 1 : grid.dims(1)
        for cc = 1 : grid.dims(2)
            rwin = round(grid.r(rr,cc) + (-grid.win/2 : grid.win/2));
            cwin = round(grid.c(rr,cc) + (-grid.win/2 : grid.win/2));
            
            pt(rwin,cwin) = grid.thresh(rr,cc);
        end
    end

end