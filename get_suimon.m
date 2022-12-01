%% Data downloader from Suimon Suishitsu database
% coded by T.Koshiba, DPRI
% history   T.Koshiba
%           08 JUN 2019, v1
%           30 JUL 2020, v2
%               : major change
%           14 AUG 2020
%               : Debug to be able to deal with a year with partial data
%           23 NOV 2022
%               : update to address for the change of web address
% suimon suishitsu database (水文水質データベース)
% http://www1.river.go.jp/
%
%
%
%
%

%%
function get_suimon(observation_point, loc_name, item, BGNYEAR, ENDYEAR)
% clear all; clc;
%==========================================================================
%                                Inputs 
%==========================================================================
% Observatory number (観測所記号 )
% observation_point = '306041286606290'; 

% location number, this will be used for output files
% loc_name = 'Kameoka';  

% what kind of information would you like to download?
% 1 = Water discharge
% 2 = Water depth
% 3 = Precipitation
% item = 1; 

% start and end year, month
% BGNYEAR = 2015;
% ENDYEAR = 2015;
BGNMNTH = 1;
ENDMNTH = 12;
%

%==========================================================================
%==========================================================================

% Make a month and date list
items = {'DspWaterData.exe?KIND=5',...
         'DspWaterData.exe?KIND=1',...
         'DspRainData.exe?KIND=1'};

url = sprintf('http://www1.river.go.jp/cgi-bin/%s&ID=%s&BGNDATE=%%s&ENDDATE=%%s&KAWABOU=NO'...
              ,items{item}, observation_point);

% make a the target dates list
[Num_year, Num_mnth, DATES] = makeDatesList(BGNYEAR, ENDYEAR, BGNMNTH, ENDMNTH);

% Run
maxD    = zeros(fix(Num_mnth/12), 3);
maxDays = cell(fix(Num_mnth/12), 1);
options = weboptions('CharacterEncoding', 'Shift_JIS', 'Timeout', Inf);
data_aYear = [];
date_aYear = {};
% NaN_rate = zeros(fix(Num_mnth/12), 1);
dataAll  = zeros(366*24, Num_year);
%
for I = 1:Num_mnth
    url_1 = sprintf(url, DATES{I, 1}, DATES{I, 2});
    S = webread(url_1, options);
    url_data = extractBetween(S,'<A href="','" TARGET=');
    url_data = url_data{1};
    url_data = sprintf('http://www1.river.go.jp/%s', url_data);
    % read data from website
    D = webread(url_data, options);
    pause(1.0)
    if I == 1
        meta = strsplit(D, '#');
        meta = meta{1};
    end
    D = strsplit(D,'#\r\n');
    D =D{3};
    
    % output data
    if not(exist('res','dir')); mkdir('res'); end
    fname = extractBefore(DATES{I, 1}, 7);
    fname = sprintf('res/%s_%s.txt', loc_name, fname);
    dlmwrite(fname, D, '');
end

end