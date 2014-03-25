%% Analyze Image
%  Matlab Colony Analyzer Toolkit
%  Gordon Bean, December 2012
%
% Parameters
% ------------------------------------------------------------------------
% outputExtension <'.cs.txt'>
%  - results will be stored in <original_filename>.<outputExtension>
% measurementLabels <'area'>
%  - When multiple quantification methods are used, these labels are used
%  as column headers in the output file.
%
% All parameters are passed to measure_colony_sizes.

% (c) Gordon Bean, August 2013

function analyze_image( filename, varargin )
    params = default_param( varargin, ...
        'outputExtension', '.cs.txt', ...
        'binaryExtension', '.binary');
    
    %% Measure colony sizes
    [cs, grid] = measure_colony_sizes( filename, varargin{:} );
    if (iscell(cs) && isempty(cs)) || (~iscell(cs) && all(in(isnan(cs))))
        % The user canceled the manual analysis.
        return;
    end
    
    %% Print .TXT file
    % Determine measurement labels
    if isfield(params, 'metric')
        if ~iscell(params.metric)
            params.metric = {params.metric};
        end
        labels = cell(size(params.metric));
        for ii = 1 : length(params.metric)
            labels{ii} = params.metric{ii}.label;
        end
    else
        labels = {'size'};
    end
    
    % Format measurement data
    if iscell(cs)
        tmp = cellfun(@in, cs, 'uniformOutput', 0);
        tmpcs = cat(2, tmp{:});
    else
        tmpcs = cs(:);
    end
    
    [rr, cc] = ind2sub( grid.dims, 1 : prod(grid.dims) );
    fid = fopen( [filename params.outputextension], 'wt');
    n = length(labels);
    fprintf(fid, ['row\tcolumn' repmat('\t%s',[1 n]) '\n'], labels{:});
    iprintf(fid,['%i\t%i' repmat('\t%f',[1 n]) '\n'], rr(:), cc(:), tmpcs);
    
    fclose(fid);
    
    %% Save grid data
    grid.info.file = fullpath(filename);
    save( [filename '.info.mat'], '-struct', 'grid' );
    
    %% Save binary image
    imwrite(grid.thresh, [filename params.binaryextension], 'png');
    
    %% Function: fullpath
    function file = fullpath( file )
        if (file(1) ~= '/')
            % Not absolute path
            file = [pwd '/' file];
        end
    end

end