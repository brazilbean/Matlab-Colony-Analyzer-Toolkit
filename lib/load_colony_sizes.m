%% Load Colony Sizes
% Gordon Bean, December 2012

function [cs files] = load_colony_sizes( filename )

    if (isdir(filename))
        % Directory of files
        files = dirfiles( filename, '*.cs.txt', true );
        n = length(files);
        cs = cell(n,1);
        
        for ff = 1 : n
            cs{ff} = load_file( files{ff} );
        end
        cs = cat(1, cs{:});
        
    else
        % Single file
        cs = load_file( filename );
        files = {filename};
    end
    
    function cs = load_file( filename )
        tmp = filescan( filename, '%f %f %f', 'headerlines', 1);

        % Get row and column subscripts
        rr = tmp{1};
        cc = tmp{2};

        % Get dimensions
        nr = max(rr);
        nc = max(cc);
        cs = nan(1, nr*nc);

        % Copy colony sizes
        ii = sub2ind( [nr nc], rr, cc );
        cs(ii) = tmp{3};
    end
end