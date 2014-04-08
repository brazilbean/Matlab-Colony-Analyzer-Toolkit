%% CONVERT_RAW_TO_TIFF
% Gordon Bean, March 2014
% Workflow and details obtained from:
%  "Processing RAW Images in MATLAB" by Rob Summer, Feb 2014, UC Santa Cruz
%  http://users.soe.ucsc.edu/~rcsumner/rawguide/RAWguide.pdf
%
% Syntax
% tiff = convert_raw_to_tiff( filename );
% [tiff, black, saturation, multipliers] = convert_raw_to_tiff( filename );
%
% Description
% tiff = convert_raw_to_tiff( filename ) converts the file indicated by
% FILENAME to a .tiff file and returns the new filename as TIFF.
%
% [tiff, black, saturation, multipliers] = convert_raw_to_tiff( filename)
% returns the image color information reported by DCRAW.
%
% ... = convert_raw_to_tiff(filename, 'Name', Value) accepts parameters
% from the following list (defaults in <>):
%  'saveSpecs' <true> - if true, saves the black, saturation, and
%  multiplier information from DCRAW in a .MAT file named after the TIFF
%  filename.
%
% convert_raw_to_tiff depends on DCRAW, which must be installed separately.
%

function [tiff, black, saturation, multipliers] = ...
    convert_raw_to_tiff( filename, varargin )
    params = default_param( varargin, ...
        'saveSpecs', true );
    
    if nargout > 1 || params.savespecs
        %% Get preliminary information
        tmp = systemf('dcraw -v -w -T %s', filename);

        %% Parse preliminary information
        foo1 = regexp(tmp, 'darkness (\d+), saturation (\d+)','tokens');
        foo2 = regexp(tmp, ['multipliers' repmat(' ([\.\d]+)', [1 4])], ...
            'tokens'); 

        foo1 = cellfun(@str2double, foo1{1});
        black = foo1(1);
        saturation = foo1(2);
        
        multipliers = cellfun(@str2double, foo2{1});
    end
    
    %% Convert NEF to TIFF
    tmp = systemf('dcraw -v -4 -D -T %s', filename);
    tmp = regexp(tmp,'data to (.+\.tiff)', 'tokens');
    tiff = tmp{1}{1};
    
    if params.savespecs
        save([tiff '.mat'], 'black', 'saturation', 'multipliers');
    end
    
end