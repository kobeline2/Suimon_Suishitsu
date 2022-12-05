path = "res/d_1989.mat";
seqHours = 24;

[v, bgnDay, endDay] = getAnnualMax(path, seqHours);


function [v, bgnDay, endDay] = getAnnualMax(path, seqHours)
dYear = load(path, "-mat", "dYear");
dYear = dYear.dYear;
d = dYear.value;
M = movmean(d, seqHours, 'Endpoints','discard');
[~, bgnDay] = max(M);
endDay = bgnDay + seqHours - 1;
v = sum(d(bgnDay:endDay));
bgnDay = dYear.time(bgnDay);
endDay = dYear.time(endDay);

end

