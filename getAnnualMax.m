function getAnnualMax()
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

