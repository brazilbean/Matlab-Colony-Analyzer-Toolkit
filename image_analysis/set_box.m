%% Get Box
% Gordon Bean, November 2012

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
