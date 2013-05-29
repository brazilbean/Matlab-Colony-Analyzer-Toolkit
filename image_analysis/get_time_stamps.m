%% Get time stamps
% Load the DateTime field from the image data for the specified files
% Gordon Bean, May 2013

function times = get_time_stamps( imagedir, varargin )
    
    % Get files
    files = dirfiles(imagedir, varargin{:});
    
    % n x [year month day hour minute second]
    times = nan(length(files), 6);
    warning('off','MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero')
    for fi = 1 : length(files)
        info = imfinfo(files{fi});
        tmp = textscan(info.DateTime, '%f:%f:%f %f:%f:%f');
        times(fi,:) = cat(2, tmp{:});
    end
    warning('on','MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero')
end