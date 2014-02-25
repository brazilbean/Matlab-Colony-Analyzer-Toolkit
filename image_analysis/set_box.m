%% Set Box - copy the contents of a smaller matrix into a larger matrix
% Gordon Bean, November 2012
%
% Syntax
% PLATE = set_box( PLATE, BOX, RPOS, CPOS )
%
% Description
% PLATE = set_box( PLATE, BOX, RPOS, CPOS ) copies the values in BOX into
% PLATE in the region defined by the dimensions of BOX centered at RPOS,
% CPOS. It is essentially the reverse of get_box.

function plate = set_box( plate, box, rpos, cpos )
    win = (size(box,1)-1)/2;
    
    rpos = round(rpos);
    cpos = round(cpos);
    
    if (islogical( box ))
        plate( rpos - win : rpos + win, cpos - win : cpos + win ) =  ...
            plate( rpos - win : rpos + win, cpos - win : cpos + win ) |box;
    else
        plate( rpos - win : rpos + win, cpos - win : cpos + win ) = box;
    end
end
