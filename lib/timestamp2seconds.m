%% timestamp2seconds - convert a time stamp to seconds
% Matlab Colony Analyzer Toolkit
% Gordon Bean, August 2013

function secs = timestamp2seconds( time )

    secs = zeros(size(time,1),1);
    for ii = 1 : size(time,1)
        secs(ii) = sub_t2s(time(ii,:));
    end
    
    function secs = sub_t2s(time)
        % Account for 1 indexed time counting
        time = time - 1;

        % Convert years since 1900
        year = time(1) - 1900;
        years = (1:year)';
        numleaps = sum( ...
            (mod(years,400)==0 | mod(years,4)==0) & ~mod(years,100)==0);

        perMin = 60;
        perHour = perMin * 60;
        perDay = perHour * 24;
        perYear = perDay * 365;

        yearsecs = year*perYear + numleaps*perDay;

        % Convert months
        dayspermonth = [31 28 31 30 31 30 31 31 30 31 30 31];
        monthsecs = sum(dayspermonth(1:time(2)))*perDay;

        % Convert days
        daysecs = time(3)*perDay;

        % Convert hours
        hoursecs = time(4)*perHour;

        % Convert minutes
        minsecs = time(5)*perMin;

        % Sum all seconds
        secs = 1 + time(6) + ...
            minsecs + hoursecs + daysecs + monthsecs + yearsecs;

    end
end