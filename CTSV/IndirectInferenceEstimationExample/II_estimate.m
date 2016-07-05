1;

function m = moments(theta, Zn, S, RNGstate)
    E_Z = theta-theta;
    theta = [theta; zeros(5,1)];
    numok = 0;
    for s = 1:S
        rand("state", RNGstate + s); % reset seed to control chatter
        delta = 5; % time delta in minutes
        M = 24*60/delta; % number of delta minute periods in a 24 hour day 
        MM = 6.5*60/delta; % number of delta minute periods in 5.5 hour trading day (S&P500 has 5.5 hour long trading period)
        MMM = 1; % number of periods between RV contributions. The SP500 data uses 5 minute intervals, so we want delta*MMM=5
        burnin = 200; % burnin in days
        n = 349;
        nshocks = (n + burnin)*M + 100;
        shocks = [randn(nshocks,3) rand(nshocks,1) randn(nshocks,1)];
        [rets, RV5, RV10, BVs, MedRVs, njumps, tjumps, hs, lambda] = CTSVmodelWithShocks(theta, n, burnin, M, MM, MMM, shocks);
        Z = aux_stat([rets, RV5, BVs]);
        ok = Z(1,1) != -1000;
        numok = numok + ok;
        if ok
            Z = NNstat(Z')';
            Z = Z(1:6,:);
            E_Z = E_Z + Z;
        end    
    end
    m = Zn-E_Z/numok;
end 

function obj = obj_function(theta, Zn, S, RNGstate)
    m = moments(theta, Zn, S, RNGstate);
    obj = m'*m;
end    

% This code does indirect inference estimation of the CTSV model
dovarcov = true;
S = 50; % number of simulations to compute Ehat(Zs)
load Zn20152016;
Zn = NNstat(Zn')';
% get RNG state to control chatter
RNGstate = rand("state");
% start II loop here
theta = Zn; % use the NN estimate as start value
printf("initial NN estimate\n");
theta
printf("note that  lam0 is slightly smaller than 0\n");
printf("so jumps never occur, and muj, sigj are not identified\n");
printf("so we set them to zero, and estimate a model without jumps\n");
theta = theta(1:6,:);
Zn = Zn(1:6,:);

# SA controls
s = abs(theta);
parameters;
lb_ub = lb_ub(1:6,:);
lb = theta - 0.3*abs(theta);
ub = theta + 0.3*abs(theta);
nt = 3;
ns = 3;
rt = 0.9; # careful - this is too low for many problems
maxevals = 1e10;
neps = 5;
functol = 1e-10;
paramtol = 1e-3;
verbosity = 2; # only final results. Inc
minarg = 1;
control = { lb, ub, nt, ns, rt, maxevals, neps, functol, paramtol, verbosity, 1};
args = {theta, Zn, S, RNGstate};
[thetahat, obj_value, convergence] = samin('obj_function', args, control);

% results from previous run
% want to show sensitivity, and compare to ses. D is large Omega small
% thetahat = [-0.048504; 0.079646; 0.290926; 0.193066; 0.650117; -0.515694];

if dovarcov
    R = 200;
    vc_reps = zeros(R,rows(thetahat));
    for r = 1:R
        vc_reps(r,:) = moments(thetahat, Zn, S, 10*RNGstate + r)';
    end    
    Omega = cov(vc_reps);
    D = numgradient("moments", {thetahat, Zn, S, RNGstate});
    Dinv = inv(D);
    VC = Dinv'*Omega*Dinv;
    se = sqrt(diag(VC));
    se'
end   



