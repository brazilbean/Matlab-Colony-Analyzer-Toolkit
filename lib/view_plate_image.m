%% View Plate Image
% Gordon Bean, December 2012

function params = view_plate_image( filename, varargin )
    params = get_params( varargin{:} );
    
    params = default_param( params, 'showimage', true );
    params = default_param( params, 'interactive', false );
    params = default_param( params, 'showgrid', false );
    params = default_param( params, 'showaxes', false );
    params = default_param( params, 'newfigure', params.interactive );
    params = default_param( params, 'notes', [] );
    params = default_param( params, 'applyThreshold', false );
    params = default_param( params, 'maskThreshold', false );
    
    params = default_param ...
        ( params, 'gridParams', {15, [0.2 0.2 1], 'filled'});
    params = default_param ...
        ( params, 'noteParams', {15, [1 0.2 0.1] });
    
    if (iscell(filename))
        filename = filename{1};
    end
    
    
    %% Load image and image info
    if (ischar(filename))
        % Fix filename
        if (strcmpi(filename(end-3:end), '.mat'))
            filename = filename(1:end-9);
        elseif (strcmpi(filename(end-6:end),'.cs.txt'))
            filename = filename(1:end-7);
        end
        
        % Load grid
        infofile = [filename '.info.mat'];
        
        if (~isfield( params, 'grid' ))
            grid = load( infofile );
        else
            grid = params.grid;
        end
        
        % Load plate
        if isfield(params, 'plateloader')
            plate = params.plateloader(filename);
        else
            if isfield(grid.info, 'PlateLoader')
                plate = grid.info.PlateLoader(filename);
            else
                if (strcmpi(filename(end-3:end),'png'))
                    warning('Guessing plate is in raw format');
                    pl = PlateLoader('channel', 2);
                else
                    warning('Guessing plate is .JPG');
                    pl = PlateLoader();
                end
                plate = pl.load(filename);
            end
        end
        
    else
        plate = filename;
        
        % Load grid
        if (~isfield(params, 'grid'))
            grid = determine_colony_grid(plate, varargin{:});
        else
            grid = params.grid;
        end
    end
    
    params.grid = grid;
    
    if (~isfield(params, 'title'))
        if (ischar( filename ) )
            tmp = textscan(filename, '%s', 'delimiter', '/');
            params.title = tmp{1}{end};
        else
            params.title = [];
        end
    end
    
    %% Show image
    dims = grid.dims;
    
    notes = false( prod(dims), 1);
    notes( params.notes ) = true;
    
    if (params.showimage)
        if (params.newfigure)
            fig = figure('color','w','position', [0 0 1000 800]);
            movegui(fig, 'center');
            set(fig, 'keyPressFcn', @close_figure);
            params.fig = fig;
        else
            fig = gcf;
        end
        draw_plate;
        draw_instructions;
        
        % Highligh notes, if any
        if (~isempty(params.notes))
            draw_notes;
        end

        % Title
        if (~isempty(params.title))
            draw_title;
        end

        % Finish
        if (params.interactive)
            disp('Select the colonies, then press any key to continue\n');
            figure(fig);
            waitfor( fig );
            
            
%             try
%                 close( fig );
%             catch e
%                 
%             end
        end
        
        params.notes = find(notes);
            
    end
    
    %% Finish
    if (nargout < 1)
        clear params 
    else
        params.notes = find(notes);
        params.image = plate;
        
    end
    
    %% Function draw_plate
    function draw_plate
        if (params.applythreshold)
            if (islogical(params.applythreshold))
                
                if (isfield( grid, 'threshed') || islogical(grid.thresh))
                    if (islogical(grid.thresh))
                        im = imagesc(grid.thresh);
                    else
                        im = imagesc( grid.threshed );
                    end
                else
                    pthresh = make_plate_threshold( plate, grid );
                    im = imagesc(plate > pthresh);   
                end
                
            else
                im = imagesc(plate > params.applythreshold);
                
            end
            
        elseif (params.maskthreshold)
            plate2 = plate;
            if (isfield( grid, 'threshed') || islogical(grid.thresh))
                if (islogical(grid.thresh))
                    plate2(grid.thresh) = median(plate(:));
                else
                    plate2( grid.threshed ) = median(plate(:));
                end
            else
                plate2( plate > make_plate_threshold( plate, grid ) ) =...
                    median(plate(:));   
            end
            
            im = imagesc(plate2);
            caxis([ min(plate(:)), max(plate(:))]);
        else
            im = imagesc(plate);
        end
        colormap(gray);
        
        if (params.showaxes)
            set(gca, 'xtick', grid.c(dims(1)/2,:), ...
                'ytick', grid.r(:,dims(2)/2), ...
                'xticklabel', 1:dims(2), 'yticklabel', 1:dims(1) );
        else
%             axis off;
            set(gca, 'xtick', [], 'ytick', [] );
            
        end
        if (params.interactive)
            set(im, 'ButtonDownFcn', @get_coords);
        end
        if (params.showgrid)
            draw_grid;
        end
    end

    %% Function get_coords
    function get_coords( varargin )
        pos = get(gca, 'CurrentPoint');
        r = pos(1,2);
        c = pos(1,1);
        
        foo = abs(grid.r - r) + abs(grid.c - c);
        [~, ii] = min( foo(:) );
        
        add_note( ii );
    end
    
    %% Function add_note
    function add_note( note )
        notes(note) = ~notes(note);
        
        draw_plate;
        draw_notes;
        draw_title;
        draw_instructions;
    end

    %% Function draw_notes
    function draw_notes 

        hold on; 
        rh = scatter( grid.c(notes), grid.r(notes), ...
            params.noteparams{:} ); 
        hold off;
        if (params.interactive)
            set(rh, 'ButtonDownFcn', @get_coords);
        end
        
%         for ni = find(notes)'
%             [rr cc] = ind2sub(dims, ni);
%             rpos = grid.r(rr,cc);
%             cpos = grid.c(rr,cc);
%             rh = rectangle('Position', [cpos-win/2 rpos-win/2 win win], ...
%                 'Curvature', [1 1],'linewidth',2, 'edgeColor','r');
%             if (params.interactive)
%                 set(rh, 'ButtonDownFcn', @get_coords);
%             end
%         end
    end

    %% Function draw_grid
    function draw_grid
        
        hold on; 
        rh = scatter( grid.c(:), grid.r(:), params.gridparams{:} );
        hold off;
        if (params.interactive)
            set(rh, 'ButtonDownFcn', @get_coords);
        end
        
    end

    %% Function draw_title
    function draw_title
        title(params.title, 'interpreter', 'none', 'fontsize', 14);
    end
    
    %% Function draw_instructions
    function draw_instructions
        if (params.interactive)
        xlabel('Select the colonies, then press any key to continue.',...
            'fontsize', 14, 'fontWeight', 'bold');
        end
    end

    function close_figure ( varargin )
        try
            close(fig);
        catch e
        
        end
    end
end