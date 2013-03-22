%% Box props
% Gordon Bean, February 2013

function props = boxprops( box, varargin )
    props = struct;
    
    for prop = varargin(:)'
        switch lower(prop{1})
            case 'lowermode'
                if (~isfield(props, 'lowermode'))
                    props.(prop{1}) = lower_mode(box);
                end
                
            case 'uppermode'
                props.(prop{1}) = upper_mode(box);
                
            case 'lowerstd'
                if (~isfield(props, 'lowermode'))
                   props.lowermode = lower_mode(box);
                end
                props.(prop{1}) = lower_std( box, props.lowermode );
                
            case 'upperstd'
                if (~isfield(props, 'lowermode'))
                   props.lowermode = lower_mode(box);
                end
                props.(prop{1}) = upper_std( box, props.lowermode );
                
            case 'max'
                props.(prop{1}) = max(box(:));
                
            case 'spotintensity'
                if (~isfield(props, 'lowermode'))
                   props.lowermode = lower_mode(box);
                end
                if (~isfield(props, 'lowerstd'))
                   props.lowerstd = lower_std(box);
                end
                i = props.lowermode + props.lowerstd*4.5;
                props.(prop{1}) = mean( box( box > i ));
                
            case 'threshold'
                if (~isfield(props, 'lowermode'))
                   props.lowermode = lower_mode(box);
                end
                if (~isfield(props, 'lowerstd'))
                   props.lowerstd = lower_std(box, props.lowermode);
                end
                props.(prop{1}) = props.lowermode + 4.5*props.lowerstd;
                
            otherwise
                fprintf('  Unrecognized option: %s', prop{1});

        end
    end
    
    function pm = lower_mode( box )
        it = (max(box(:)) + min(box(:)))/2;
        pm = parzen_mode(box(box<it));
        c = 10;
        while (c > 0 && pm > it)
            pm = parzen_mode(box(box<it));
            it = (it + min(box(:)))/2;
            c = c - 1;
        end
    end

    function pm = upper_mode( box )
        it = (max(box(:)) + min(box(:)))/2;
        pm = parzen_mode(box(box>it));
        c = 10;
        while (c > 0 && pm < it)
            it = (it + max(box(:)))/2;
            pm = parzen_mode(box(box>it));
            c = c - 1;
        end
    end

    function st = lower_std( box, pm )
        tmp = box(box<pm)-pm;
        st = std([tmp; -tmp]);
    end

    function st = upper_std( box, pm )
        tmp = box(box>pm)-pm;
        st = std([tmp; -tmp]);
    end
end