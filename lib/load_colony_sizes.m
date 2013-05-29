%% Load Colony Sizes
% Gordon Bean, December 2012

function [cs files] = load_colony_sizes( filename, varargin )
    params = default_param(varargin, ...
        'extension', '.cs.txt');

    ext = ['*' params.extension];
    if (isdir(filename))
        % Directory of files
        files = dirfiles( filename, ext );
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
        filename = get_cs_txt_file( filename );
        tmp = filescan( filename, '%f %f %f %*[^\n]', 'headerlines', 1);

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

    function file = get_cs_txt_file( file )
        if (length(file) > 7 && strcmp(file(end-6:end),'.cs.txt'))
            return;
        elseif (length(file) > 4 && strcmpi(file(end-3:end),'.JPG'))
            file = [file '.cs.txt'];
        elseif (length(file) > 9 && strcmp(file(end-9:end),'.info.mat'))
            file = [file(1:end-9) '.cs.txt'];
        end
    end
end