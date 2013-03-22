%% Estimage Intensity Threshold
% Gordon Bean, March 2012

function thresh = estimate_intensity_threshold( img )
    
    %% Find middle box
    w = floor(min(size(img)/10));
    tmp = floor(size(img)/2);
    rmid = tmp(1);
    cmid = tmp(2);
    box = img(rmid-w:rmid+w, cmid-w:cmid+w);
    
    %% Estimate Threshold
    thresh = ( min(box(:)) + max(box(:)) ) / 2;
%     thresh = ( prctile(box(:),5) + prctile(box(:),95) ) / 2;
    
    %% Walk-through figures
%     figure;
%     imagesc(img)
%     colormap gray
%     colorbar
%     qline(cmid-w, [rmid-w rmid+w], 'r');
%     qline(cmid+w, [rmid-w rmid+w], 'r');
%     qline([cmid-w cmid+w], rmid-w, 'r');
%     qline([cmid-w cmid+w], rmid+w, 'r');
%     qtitle('Find the internal of the plate');
%     
%     figure;
%     plot(sort(box(:)),'linewidth', 2);
%     labels('Sorted Pixels','Intensity');
%     qline(xlim, prctile(box(:),5), 'r');
%     qline(xlim, prctile(box(:),95), 'r');
%     qline(xlim, thresh, 'k', 2);
%     legend('Pixels','5th Percentile','95th Percentile','Threshold', ...
%         'location','nw');
%     pretty_figure;
%     qtitle('Intensity threshold for colonies')
%     
end