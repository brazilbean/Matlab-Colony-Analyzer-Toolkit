%% Analyze Directory of Images
% Gordon Bean, December 2012

function analyze_directory_of_images( imagedir, varargin )
    params = get_params( varargin{:} );
    params = default_param( params, 'extension', '.JPG');
    params = default_param( params, 'verbose', false );
    params = default_param( params, 'parallel', false );
    
    %% Get Image Files
    files = dirfiles( imagedir, ['*' params.extension] );
    
    %% Scan each file
    if (params.parallel)
        if (matlabpool('size') == 0)
            matlabpool
        end
        verb = params.verbose;
        parfor ff = 1 : length(files)
            try
                verbose( verb, ' Analyzing: %s\n', files{ff});
                analyze_image( [imagedir files{ff}], varargin{:} );
            catch e
                warning('Image %s/%s failed: %s\n', imagedir, files{ff}, ...
                    e.message );
            end
        end

    else
        for ff = 1 : length(files)
            try
                verbose( params.verbose, ' Analyzing: %s\n', files{ff});
                analyze_image( [imagedir files{ff}], varargin{:} );
            catch e
                warning('Image failed:\n %s/%s\n  %s\n', ...
                    imagedir, files{ff}, e.message );
            end
        end
    end
end