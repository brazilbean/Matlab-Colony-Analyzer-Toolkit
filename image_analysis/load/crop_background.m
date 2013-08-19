%% Crop Background
% Matlab Colony Analyzer Toolkit
% Gordon Bean, April 2012
%
% Crops a plate image to the plate. 
%
% Parameters
% ------------------------------------------------------------------------
% offset <0>
%  - the width of the margin surrounding the plate
%

% (c) Gordon Bean, August 2013

function [plate crop] = crop_background( img, varargin )
    params = get_params( varargin{:} );
    params = default_param( params, 'offset', 0 );
    if (ischar(params.offset) && strcmpi(params.offset, 'default'))
        params.offset = round(size(img,1)/20);
    end
    
    background_thresh = 0.9;
    
    % Estimate background intensity
    foo = mean(img);
    fmid = floor(length(foo)/2);
    w = floor(fmid/6);
    bthresh = min( foo( fmid-2*w : fmid+2*w ) );
    
    % Walk-through figure
%     figure;
%     plot(foo, 'linewidth', 1.5);
%     qline(fmid-2*w, ylim, 'k');
%     qline(fmid+2*w, ylim, 'k');
%     qline(xlim, bthresh, 'r');
%     legend('Mean of img', 'middle-w','middle+w','Threshold');
%     qtitle('Finding the plate threshold');
%     pretty_figure;
    
    % Crop
    tmpb = mean(img < bthresh,2) < background_thresh; 
    crop(1) = max(1, find( tmpb, 1, 'first') - params.offset);
    crop(2) = min(length(tmpb), find( tmpb, 1, 'last') + params.offset);
    
    tmpb = mean(img < bthresh,1) < background_thresh;
    crop(3) = max(1, find( tmpb, 1, 'first') - params.offset);
    crop(4) = min(length(tmpb), find( tmpb, 1, 'last') + params.offset);
    
    plate = img(crop(1):crop(2), crop(3):crop(4));
    
    % Walk-through figure
%     figure;
%     imagesc(img);
%     colormap gray;
%     qline(crop(3), ylim, 'r');
%     qline(crop(4), ylim, 'r');
%     qline(xlim, crop(1), 'r');
%     qline(xlim, crop(2), 'r');
%     qtitle('Cropped plate, offset = %i', params.offset);
%     pretty_figure

end