%% Generate array labels from 96-well plate numbers
% Gordon Bean, July 2013
%
% list - the list the IDs of the 96-well plates that comprise your array
% set. This should be a vector of integers.
% 
% dims - the dimensions of the array set. E.g. [32 48] or [64 96]
%
% labelfile - the text file containing the following columns:
%  ORF    96-well ID    96-well row    96-well column
% See the provided default file for an example. The provided default has
% the ORF names of the Ideker Lab copy of the yeast genome knock-out
% collection.
%

function labels = generate_array_labels( list, dims, labelfile )
    if nargin < 3
        labelfile = 'lib/Phil_mat_a_ko_library_mapping_file.txt';
    end

    %% Check list for correct length
    % Should be a power of 4
    n = log(length(list))/log(4);
    if fix(n) ~= n
        error('First argument length must be a power of 4: %i', ...
            length(list));
    end
    
    %% Load 96-well labels file
    source = filescan(labelfile, '%s %f %s %f');
    [orfs, plateID, rows, cols] = deal(source{:});
    rows = cellfun(@(x) x - 'A' + 1, rows);
    
    %% Get indexes
    inds = get_96_format_indexes( dims );

    %% Mash
    labels = cell(dims);
    myplates = list(inds(:,:,1));
    myrows = inds(:,:,2);
    mycols = inds(:,:,3);
    
    % Check for missing plates
    for ii = list(:)'
        if sum(plateID == ii) == 0
            warning('96-well plate not found: %i', ii);
        end
    end
    
    % Copy labels
    for ii = 1 : numel(labels)
        tmp = orfs(myplates(ii) == plateID ...
            & rows == myrows(ii) & cols == mycols(ii));
        if isempty(tmp)
            tmp = {''};
        end
        labels{ii} = tmp{:};
    end
    
end