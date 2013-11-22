%% Get Box
% Gordon Bean, November 2012

function box = get_box( plate, rpos, cpos, win )
    rpos = round(rpos);
    cpos = round(cpos);
    win = round(win);
    box = plate( rpos - win : rpos + win, cpos - win : cpos + win, : );

end
