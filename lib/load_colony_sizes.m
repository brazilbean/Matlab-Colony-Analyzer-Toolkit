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
        if isstruct(cs{1})
            % Multiple measurements returned
            % Combine array of structs into struct with array fields
            cs = cat(1, cs{:});
            cs_ = struct;
            for ff = fieldnames(cs)'
                cs_.(ff{:}) = cat(1, cs.(ff{:}));
            end
            cs = cs_;
        else
            % Single measurement returned
            cs = cat(1, cs{:});
        end
        
    else
        % Single file
        cs = load_file( filename );
        files = {filename};
    end
    
    function cs = load_file( filename )
        filename = get_cs_txt_file( filename );
        
        % Determine number of columns
        fid = fopen(filename);
        header = fgetl(fid);
        fields = textscan(header, '%s');
        fields = fields{1};
        ncols = length(fields);
        fclose(fid);
        
        format = [repmat(' %f', [1 ncols]) ' %*[^\n]'];
        tmp = filescan( filename, format, 'headerlines', 1);

        % Get row and column subscripts
        rr = tmp{1};
        cc = tmp{2};

        % Get dimensions
        nr = max(rr);
        nc = max(cc);
        
        % Copy colony sizes
        ii = sub2ind( [nr nc], rr, cc );
        if (length(tmp) < 4)
            % Only one set of measurements
            cs = nan(1, nr*nc);
            cs(ii) = tmp{3};
        else
            % Two or more measurements - return a struct
            cs = struct;
            for f = 3 : length(fields)
                cs.(fields{f}) = nan(1, nr*nc);
                cs.(fields{f})(ii) = tmp{f};
            end
            
        end
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