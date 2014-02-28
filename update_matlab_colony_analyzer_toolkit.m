%% UPDATE MATLAB COLONY ANALYZER TOOLKIT
% Matlab Colony Analyzer Toolkit
% Gordon Bean, February 2014
%
% Syntax
% update_matlab_colony_analyzer_toolkit();
% update_matlab_colony_analyzer_toolkit('Name', Value, ...);
%
% Description
% update_matlab_colony_analyzer_toolkit() downloads the zipped Matlab
% Colony Analyzer Toolkit repository from github.com and extracts the files
% to the current location of the toolkit (or a specified location).
%
% update_matlab_colony_analyzer_toolkit('Name', Value, ...) accepts
% name-value parameters from the following list:
%  'path' - a string specifying the path to install the toolkit. If not
%  provided, update_matlab_colony_analyzer_toolkit will determine the
%  current location of the toolkit and overwrite your current copy. 
%
%  'url' - a string specifying the URL of the ZIP file to be downloaded.
%  You probably won't change this.
%
%  'verbose {true} - if false, the progress messages will not be displayed.
%

function update_matlab_colony_analyzer_toolkit( varargin )
    params = default_param( varargin, ...
        'path', '', ...
        'url', ['https://github.com/brazilbean/' ...
            'Matlab-Colony-Analyzer-Toolkit/archive/master.zip'], ...
        'verbose', true);
    
    % Determine the location of the toolkit
    if isempty(params.path)
        foo = which('update_matlab_colony_analyzer_toolkit');

        tmp = textscan(foo, '%s', 'delimiter', '/');
        params.path = sprintf('%s/', tmp{1}{1:end-2});
    end
    verbose(params.verbose, ...
        'The toolkit will be installed in %s\n', params.path);
    
    % Download .ZIP file
    verbose(params.verbose, 'Downloading the ZIP archive...\n');
    zipfile = urlwrite(params.url, '/tmp/mcat.zip/');
    
    % Extract files
    verbose(params.verbose, 'Extracting the ZIP contents...\n');
    unzip( zipfile, params.path );
    
    % Add MCAT to path
    addpath([params.path 'Matlab-Colony-Analyzer-Toolkit-master/']);
    add_mca_toolkit_to_path
    rehash

    verbose(params.verbose, 'Installation complete.\n\n');
end