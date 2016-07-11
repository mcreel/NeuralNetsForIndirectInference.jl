n = 349;
delta = 5; % time delta in minutes
M = 24*60/delta; % number of delta minute periods in a 24 hour day 
MM = 6.5*60/delta; % number of delta minute periods in 5.5 hour trading day (S&P500 has 5.5 hour long trading period)
MMM = 1; % number of periods between RV contributions. The SP500 data uses 5 minute intervals, so we want delta*MMM=5
burnin = 200; % burnin in days
theta = [asbil_theta; zeros(5,1)];
[rets, RV5, RV10, BVs, MedRVs, njumps, tjumps, hs, lambda] = CTSVmodel(theta, n, burnin, M, MM, MMM);
data = [rets RV5 BVs];	
