function out4suimonUtil(maxD, maxDays, meta, seqHour)
    v = maxD(:, 1);
    
    nNan = 0;
    for I = 1:length(maxDays)
        if isempty(maxDays{I})
            maxDays{I} = '000000/00/00000';
            nNan = nNan + 1;
        end
    end
    
    f = @(x) x(end-14:end-5);
    maxDays = cellfun(f, maxDays, 'UniformOutput', false);
    
    meta = strsplit(meta, '\n');
    fn = [meta{4}(6:end-1), num2str(seqHour), 'h.dat'];
    fid = fopen(fn, 'w');
    
    % header
    nData  = length(v) - nNan;
    suikei = [meta{2}(5:end-1) meta{2}(1:2)];
    kawa   = meta{3}(5:end-1);
    chiten = [meta{4}(6:end-1), num2str(seqHour), 'h'];
    formatSpec = 'VER2\n%u %s %s %s\r\n-9999 0\r\n';
    fprintf(fid, formatSpec, nData, suikei, kawa, chiten);
    
    % data
    temp = num2cell(v);
    temp = [maxDays temp];
    temp = temp';
    formatSpec = '%s %.1f\r\n';
    fprintf(fid, formatSpec, temp{:});

    fclose(fid);
end
