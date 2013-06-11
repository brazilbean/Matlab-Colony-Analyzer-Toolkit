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

function analyze_image( filename, varargin )
    params = default_param( varargin, ...
    'outputExtension', '.cs.txt', ...
    'measurementLabels', {'area'});
    
    % Check measurement labels - should be in cell array
    if ~iscell(params.measurementlabels)
        params.measurementlabels = {params.measurementlabels};
    end
    if isfield(params, 'sizefunction') && length(params.sizefunction) > 1
        % More than one measurement expected -> make sure the user supplied
        % more than one measurement label.
        
        if ~iscell(params.sizefunction) || ...
           length(params.measurementlabels) ~= length(params.sizefunction)
            error('Mismatched number of measurement functions and labels');
        end
    end
    
    %% Measure colony sizes
    [cs grid] = measure_colony_sizes( filename, varargin{:} );
    if (iscell(cs) && isempty(cs)) || (~iscell(cs) && all(in(isnan(cs))))
        % The user canceled the manual analysis.
        return;
    end
    
    %% Print .TXT file
    % Format measurement data
    if iscell(cs)
        tmp = cellfun(@in, cs, 'uniformOutput', 0);
        tmpcs = cat(2, tmp{:});
    else
        tmpcs = cs(:);
    end
    
    [rr cc] = ind2sub( grid.dims, 1 : prod(grid.dims) );
    
    fid = fopen( [filename params.outputextension], 'wt');
    n = length(params.measurementlabels);
    fprintf(fid, ['row\tcolumn' repmat('\t%s',[1 n]) '\n'], ...
        params.measurementlabels{:});
    iprintf(fid,['%i\t%i' repmat('\t%f',[1 n]) '\n'], rr(:), cc(:), tmpcs);
    
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