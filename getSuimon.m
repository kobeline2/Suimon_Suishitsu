function getSuimon(observation_point, loc_name, item, BGNYEAR, ENDYEAR)
%GET_SUIMON
%   get suimon suishitsu.
%   get_suimon(location_code, location_name, item, begin_year, end_year)
%   items: 1 = Water discharge, 2 = Water depth, 3 = Precipitation
%   Example:
%   get_suimon('306041286606290', 'Kameoka', 1, 2015, 2015)


% Make a month and date list
items = {'DspWaterData.exe?KIND=5',...
         'DspWaterData.exe?KIND=1',...
         'DspRainData.exe?KIND=1'};

urlFmt = sprintf('http://www1.river.go.jp/cgi-bin/%s&ID=%s&BGNDATE=%%s&ENDDATE=%%s&KAWABOU=NO'...
              ,items{item}, observation_point);

if not(exist('res','dir')); mkdir('res'); end
options = weboptions('CharacterEncoding', 'Shift_JIS', 'Timeout', Inf);

for year = BGNYEAR:ENDYEAR
    fn = sprintf('res/%s.txt', num2str(year));
    fid = fopen(fn, 'a+');

    for month = 1:12
        bgnDay  = [num2str(year), num2str(month, '%02.2u'), '01'];
        endDay  = [num2str(year), num2str(month, '%02.2u'), num2str(eomday(year, month))];
        url     = sprintf(urlFmt, bgnDay, endDay);
        htmlTxt = webread(url, options);
        htmlTxt = extractBetween(htmlTxt, '<A href="','" TARGET=');
        htmlTxt = htmlTxt{1};
        urlData = sprintf('http://www1.river.go.jp/%s', htmlTxt);
        data    = webread(urlData, options);
        data    = strsplit(data,'#\r\n');
        data    = data{3};
        data    = data(1:end-2);
    
        % output data
        
        dlmwrite(fid, data, '');
    end
end


end