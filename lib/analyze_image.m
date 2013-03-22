%% Analyze Image
% Gordon Bean, December 2012

function analyze_image( filename, varargin )
    output_extension = '.cs.txt';
    
    %% Measure colony sizes
    [cs grid] = measure_colony_sizes( filename, varargin{:} );
    if (isnan(cs))
        % The user canceled the manual analysis.
        return;
    end
    
    %% Print .TXT file
    [rr cc] = ind2sub( grid.dims, 1 : prod(grid.dims) );
    
    fid = fopen( [filename output_extension], 'wt');
    fprintf(fid, 'row\tcolumn\tsize\n');
    iprintf(fid, '%i\t%i\t%i\n', rr(:), cc(:), cs(:));
    
    fclose(fid);
    
    %% Save grid data
    grid.info.file = fullpath(filename);
    save( [filename '.info.mat'], '-struct', 'grid' );
    
    %% Function: fullpath
    function file = fullpath( file )
        if (file(1) ~= '/')
            % Not absolute path
            file = [pwd '/' file];
        end
    end

end