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
% clear all; clc;
%==========================================================================
%                                Inputs 
%==========================================================================
% Observatory number (観測所記号 )
observation_point = '106041286618020'; 

% location number, this will be used for output files
loc_name = 'Tonoda';  

% what kind of information would you like to download?
% 1 = Water discharge
% 2 = Water depth
% 3 = Precipitation
item = 3; 

% start and end year, month
BGNYEAR = 2015;
ENDYEAR = 2015;
BGNMNTH = 1;
ENDMNTH = 12;
%
% データをtxtとして出力するならtrue, しないならfalse
outData      = true;
outAnnualMax = false;

% sequence of seqHour hours for computing GEV
seqHour = 24;


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
    D = strsplit(D,'閉局\r\n#\r');
    D =D{2};
    
    % output data or not %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if outData
        if not(exist('res','dir')); mkdir('res'); end
        fname = extractBefore(DATES{I, 1}, 7);
        fname = sprintf('res/%s_%s.txt', loc_name, fname);
        dlmwrite(fname, D, '');
    end
    
    % ouotput annual maximum or not
    if outAnnualMax
        D = strsplit(D, ','); 
        D = reshape(D(1:end-1), 3, []);
        date = D(1:2, :);
        D    = D(3, :);
        D = cellfun(@str2double, D);
%         if isempty(D)
%             NaN_rate(I) = 1;
%         else
%             NaN_rate(I) = (sum(isnan(D)) + sum(D<0))/length(D);
%         end
        
        data_aYear = [data_aYear D];
        date_aYear = [date_aYear date];
        
        % merge each 12-month data to a yearly data
        if mod(I, 12) == 0
            if isempty(data_aYear)
                data_aYear = nan(1, 24*366);
                M = NaN;
            else
                data_aYear(data_aYear < 0)    = NaN;
                M = movmean(data_aYear, seqHour, 'omitnan', 'Endpoints','discard');
                [maxD(I/12, 1), maxD(I/12, 2)] = max(M);
                maxD(I/12, 1) = maxD(I/12, 1) * seqHour; % CAUTION! summed max value can be psedo-one when nan is contained
                maxD(I/12, 3) = BGNYEAR + I/12 - 1;
                maxDays{I/12, :} =  [date_aYear{1, maxD(I/12, 2)} date_aYear{2, maxD(I/12, 2)}];
            end
            
            % record all data in the year
            lackData = 24*366-length(data_aYear);
            if length(data_aYear) <= 8760
                data_aYear = [data_aYear nan(1, 24*366-length(data_aYear))]; 
            end
            dataAll(:, I/12) = data_aYear;
            data_aYear = []; date_aYear = {};
            disp(sprintf('%d year has finished (%d)', BGNYEAR + I/12 - 1, lackData))
        end
    end
end
%
if outAnnualMax
%     NaN_rate = reshape(NaN_rate, 12, []);
% 
%     % View NaN rate
%     figure;
%     ax = heatmap(NaN_rate'*100);
%     ax.YDisplayLabels = BGNYEAR:ENDYEAR;
%     xlabel('Month'); ylabel('Year');
%     title('NaN rate')
    
    % output for Suimon Utility
    out4suimonUtil(maxD, maxDays, meta, seqHour)
end
%%
% L = size(dataAll, 2);
% for I = 1:L
% % I = 17;
% %     subplot(L, 1, I)
%     plot([1:24*366]/24, dataAll(:, I), 'k'); hold on
%     b = double(isnan(dataAll(:, I)));
%     b(b==0) = nan;
%     scatter([1:24*366]/24, b, 'r')
%     
%     
%     iMax = maxD(I, 2);
%     if iMax ~= 0
%         dMax = dataAll(:, I);
%         dMax(1:iMax-1) = nan;
%         dMax(iMax+seqHour:end) = nan;
%         plot([1:24*366]/24, dMax, 'b', 'LineWidth', 2)
%     end
%     
%     
%     l = legend(num2str(BGNYEAR+I-1), 'NaN', 'max');
%     l.Box = 'off'; hold off
% end
%%
% clear variables
clearvars   BGNMNTH I S item options year_c J items CustomDist...
            LegHandles data_aYear loc_name seqHour D LegText date url...                
            DATES M date_aYear url_1 ENDMNTH Num_mnth hLegend mnth_c...
            url_data ENDYEAR Num_year hLine observation_point x ax...
            outAnnualMax outData l iMax dMax b 
        
%%
pd1 = fitGevSuimon(maxD)

%%



