%% Manual Binary Inspection
% Matlab Colony Analyzer Toolkit
% Gordon Bean, July 2013
%
% binfiles - may be a directory or a list of .binary files
%
% While 'y' or 'n' are suggested inputs, any annotation can be made.

function annotate = manual_binary_inspection( binfiles )

    % Setup
    if isdir(binfiles)
        binfiles = dirfiles(binfiles, '*.binary');
    end
    
    fun = @(x) stack_fun(view_binary_image(x), @snapnow, @(y)pause(0.1));

    % Annotate
    annotate = cell(size(binfiles));
    for ii = 1 : numel(binfiles)
        fun(binfiles{ii});
        annotate{ii} = ...
            input(sprintf( ...
            'Image %i - Alignment correct? (y/n): ', ii), 's');
    end
end