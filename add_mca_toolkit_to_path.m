%% Add the Matlab Colony Analyzer Toolkit to your path
% Gordon Bean, December 2012

function add_mca_toolkit_to_path

    foo = which('add_mca_toolkit_to_path');

    tmp = textscan(foo, '%s', 'delimiter', '/');
    pp = sprintf('%s/', tmp{1}{1:end-1});
    
    % Add directories
    addpath( genpath([pp '/cs_analysis']) );
    addpath( genpath([pp '/image_analysis']) );
    addpath( genpath([pp '/lib']) );
    addpath( [pp '/qc'] );

    % Check for Gordon's bag-o-tricks
    if ~exist('in.m', 'file') || ~exist('dirfiles.m','file')
        warning(['The Matlab Colony Analyzer Toolkit requires the ' ...
            'Bean Matlab Toolkit, which may be found at: \n' ...
            'https://github.com/brazilbean/bean-matlab-toolkit']);
    end
end
