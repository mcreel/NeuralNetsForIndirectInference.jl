load SP500.m;
data = [DateID ret rv5 rv10 bv medrv];

% drop missings
data(any(isnan(data),2),:)=[];
data(any(isinf(data),2),:)=[];

% scale to have returns as percentage (like ABD 2002)
rets = 100*data(:,2);
RV5 = 10000*data(:,3);
RV10 = 10000*data(:,4);
BV = 10000*data(:,5);
MedRV = 10000*data(:,6);

% get dates
date = data(:,1);
year = floor(date/10000);
md = date - year*10000;
month = floor(md/100);
day = date - year*10000 -month*100;

% define sample periods
insample = year >=2015;

% all of the data, after preparation: save to use for figures
data = [year month day rets RV5 RV10 BV MedRV];
data = data(insample,:);
save data20152016 data;
% generate Z for each subsample
data = data(:,4:end);
Zn = aux_stat(data);
save Zn20152016 Zn;



