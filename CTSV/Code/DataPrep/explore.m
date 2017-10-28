#load data20152016;
load fullsampledata;
year = data(:,1);
month = data(:,2);
day = data(:,3);
rets = data(:,4);
RVs = data(:,5);
BVs = data(:,6);
MedRVs = data(:,7);
d = data(:,4:end);
jumps1 = RVs - BVs;
jumps1 = jumps1.*(jumps1>0);
jumps2 = RVs - MedRVs;
jumps2 = jumps2.*(jumps2>0);
d = [d jumps1 jumps2];
printf("dstats rets RVs MedRVs jumps1 jumps2, no transformation\n");
dstats(d);
printf("dstats, RVs MedRVs jumps1 jumps2: sqrt(x)\n");
dstats(sqrt(d(:,2:end)));
printf("dstats, RVs MedRVs jumps1 jumps2: log(1+x)\n");
dstats(log(1+d(:,2:end)));

    


% plots comparable to Andersen, Bollerslev, Diebold, 2007, fig1, 
plot(datenum(year, month, day), RVs);
datetick('yyyy/mm','keeplimits');
grid on;
print('RVs','-dsvg');
plot(datenum(year, month, day), jumps1);
datetick('yyyy/mm','keeplimits');
grid on;
print('Jumps','-dsvg');
plot(datenum(year, month, day), rets);
datetick('yyyy/mm','keeplimits');
grid on;
print('rets','-dsvg');



printf("predictability of jumps\n");
jump = [jumps1 lags(jumps1,10)];
jump = jump(11:end,:);
y = jump(:,1);
x = [ones(rows(y),1) jump(:,2:end)];
mc_ols(y,x);

