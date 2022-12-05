function getSuimon(observation_point, item, BGNYEAR, ENDYEAR, saveas)
%GET_SUIMON
%   get suimon suishitsu.
%   get_suimon(location_code, location_name, item, begin_year, end_year)
%   items: 1 = Water discharge, 2 = Water depth, 3 = Precipitation
%   'saveas' specifies the output format; "csv"(default) or "mat".
%   Example:
%   getSuimon('306041286606290', 1, 2015, 2015, "mat")

if ~exist('saveas', 'var'), saveas = "csv"; end

ITEMS = {'DspWaterData.exe?KIND=5',...
         'DspWaterData.exe?KIND=1',...
         'DspRainData.exe?KIND=1'};

urlFmt = sprintf('http://www1.river.go.jp/cgi-bin/%s&ID=%s&BGNDATE=%%s&ENDDATE=%%s&KAWABOU=NO'...
              ,ITEMS{item}, observation_point);

options = weboptions('CharacterEncoding', 'Shift_JIS', 'Timeout', Inf);
TIMEZERO = datetime(2000, 1, 1, 0, 0, 0); 
TIMEZERO.Format = 'HH:mm';

if not(exist('res','dir')); mkdir('res'); end

for year = BGNYEAR:ENDYEAR
    try
        dYear = [];
        for month = 1:12
            bgnDay  = [num2str(year), num2str(month, '%02.2u'), '01'];
            endDay  = [num2str(year), num2str(month, '%02.2u'), num2str(eomday(year, month))];
            url     = sprintf(urlFmt, bgnDay, endDay);
            htmlTxt = webread(url, options);
            htmlTxt = extractBetween(htmlTxt, '<A href="','" TARGET=');
            htmlTxt = htmlTxt{1};
            urlData = sprintf('http://www1.river.go.jp/%s', htmlTxt);
            d       = webread(urlData, options);
            d       = strsplit(d,'#\r\n');
            d       = d{3};
            d       = d(1:end);
            dYear   = [dYear, d];
            pause(1.0)
        end
        dYear = textscan(dYear, '%{yyyy/MM/dd}D %{HH:mm}D %f %s', 'Delimiter', ',');
        dYear = dYear(1:3);
        dYear{1}(isnat(dYear{2})) = dYear{1}(isnat(dYear{2})) + days(1);
        dYear{2}(isnat(dYear{2})) = TIMEZERO;
        dYear = table(dYear{1}, dYear{2}, dYear{3}, 'VariableNames', ["time", "hrs", "value"]);
        dYear.time = dYear.time + timeofday(dYear.hrs);
        dYear.time.Format = "yyyy/MM/dd HH:mm";
        dYear = removevars(dYear, "hrs");

        % missing data
        dYear.value(dYear.value<0) = NaN;
    
        % save
        if saveas == "csv"
            writetable(dYear, "res/d_" + num2str(year) + ".csv")
        elseif saveas == string(saveas)
            save("res/d_" + num2str(year) + ".mat", "dYear");
        end
        disp("output " + num2str(year))
    catch
        disp("no data in " + num2str(year))
    end
end

end