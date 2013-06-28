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

end
