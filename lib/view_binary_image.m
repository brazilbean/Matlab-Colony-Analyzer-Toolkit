%% View binary image - load and display the binary plate image
% Matlab Colony Analyer Toolkit
% Gordon Bean, July 2013

function ax = view_binary_image( filename )

    if ~strcmp(filename(end-6:end), '.binary')
        % Assume the filename ends in .JPG
        filename = [filename '.binary'];
    end
    
    ax = imagesc(imread(filename)); 
    axis image
    colormap gray

    if (nargout < 0)
        clear ax;
    end
end