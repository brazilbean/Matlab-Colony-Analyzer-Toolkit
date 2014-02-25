%% Get Box - returns a 2D window centered at the given position of a matrix
% Gordon Bean, November 2012
%
% Syntax
% BOX = get_box( PLATE, RPOS, CPOS, WIN )
%
% Description
% BOX = get_box( PLATE, RPOS, CPOS, WIN ) returns a matrix of size 2*WIN+[1
% 1] centered at [RPOS, CPOS] in the matrix PLATE. 
%
% Example
% box = get_box( magic(7), 3, 4, 1 )

function box = get_box( plate, rpos, cpos, win )
    rpos = round(rpos);
    cpos = round(cpos);
    win = round(win);
    box = plate( rpos - win : rpos + win, ...
        cpos - win : cpos + win, : );
end
