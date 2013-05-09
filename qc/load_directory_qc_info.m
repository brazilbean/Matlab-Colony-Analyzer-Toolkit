%% Load directory QC information
% Gordon Bean, December 2012

function info = load_directory_qc_info( imagedir )

    %% Load .info.mat files
    matfiles = dirfiles( imagedir, '*.info.mat', false );
    n = length(matfiles);
    
    %% Load files
    grids = cell(n,1);
    for ff = 1 : n
        grids{ff} = load([imagedir matfiles{ff}]);
    end
    
    %% Extract grid spacing information
    info.gridspace = nan(n,1);
    for ii = 1 : n
        info.gridspace(ii) = grids{ii}.win;
    end
    
    %% Extract rotation information
    info.rotation = nan(n,1);
    for ii = 1 : n
        info.rotation(ii) = grids{ii}.info.theta;
    end
    
    %% Extract threshold information
%     info.thresh = nan(grids{1}.dims(1),grids{1}.dims(2),n);
%     for ii = 1 : n
%         info.thresh(:,:,ii) = grids{ii}.thresh;
%     end
%     
    %% File names
    info.files = cell(n,1);
    for ii = 1 : n
        info.files{ii} = grids{ii}.info.file;
    end
    
    %% Offset grids
    data = load_colony_sizes( imagedir );
    info.offset_grid = check_for_offset_grid( data, grids{1}.dims );
    
end