% is_sbil: importance sampling SBIL

outfile = "jefresults.overallmu2"

mc_reps = 100;
n = 2000; % sample size
burnin = 200; % initial obsn to drop
verbose = false;

delta = 5; % time delta in minutes
M = 24*60/delta; % number of 1 minute periods in a 24 hour day 
MM = 6.5*60/delta; % number of 1 minute periods in 5.5 hour trading day (S&P500 has 5.5 hour long trading period)
MMM = 1; % number of periods between RV contributions. The SP500 data uses 5 minute intervals, so we want delta*MMM=5
otherargs = {n, burnin, M, MM, MMM}; % arguments for dosimulation other than parameters

thetahats = zeros(mc_reps,10);
stds = zeros(mc_reps,10);

iters = 5;
nparticles = 1500; % number per round
nparticles2 = 3000; % number for last round
keep_fraction = 0.2; % fraction of best particles to keep for next round


% parameters
parameters;
lb = lb_param_sd_ub(:,1);
ub = lb_param_sd_ub(:,4);

prior_params = [lb ub];
theta = lb_param_sd_ub(:,2);
model_params = theta;
theta0 = theta;

sd_factor = 2; # the multiple of JEF stds. used for prior

setupmpi; % sets comm world, nodes, node, etc.
warning ( "off") ;
library;  % source functions usd

% number of particles for each node
particles_per_node = floor(nparticles/(nodes-1));
particles_per_node2 = floor(nparticles2/(nodes-1));

% load the sampled from prior data
if !node
	load simdatajef
	simdata = clean_data(simdatajef);
endif

for rep = 1:mc_reps
	% generate the true sample Zn on the first node, and sync it to frontend and others
	if node==1
		theta = lb_param_sd_ub(:,2); % simulate at true values
		data = dosimulation(theta, otherargs);
		Zn = aux_stat(data);
		MPI_Send(Zn, 0, mytag, CW);
		for i = 2:nodes-1
			MPI_Send(Zn, i, mytag, CW);
		endfor	
	endif
	% receive it on the other nodes
	if node !=1
		Zn = MPI_Recv(1, mytag, CW);
	endif	
	Zn = Zn';

	% main algorithm code, in one place to keep same for Monte Carlo and estimation
	is_sbil_algorithm;

	% see the results
	if !node
		thetas = contribs(:,1:rows(theta));
		Zs = contribs(:,rows(theta)+1:end);
		Z = [Zn; Zs];
		Z = st_norm(Z);
		Zs = Z(2:end,:);
		Zn = Z(1,:);
		k = rows(Zs); % use them all
		thetahat = knn_regression(Zn, thetas, Zs, k, 3, 'false');
		thetahats(rep,:) = thetahat;
		stds(rep,:) = std(thetas);
		if rep > 1
			printf("\n\nall");
			contrib = thetahats(1:rep,:);
			m = mean(contrib);
			s = std(contrib);
			e = contrib - repmat(theta0',rows(contrib),1);
			b = mean(e);
			e = e.^2;
			mse = mean(e);
			rmse = sqrt(mse);
			priormean = lb_param_sd_ub(:,2)';
			priorsdev = sd_factor*lb_param_sd_ub(:,3)';
			priorbias = priormean - theta0';
			priorrmse = sqrt(priorbias.^2 + priorsdev.^2);
			mae = mean(abs(e));
			clabels = char("true", "mean", "pmean", "sdev.","psdev", "bias", "pbias","rmse", "prmse");
			rlabels = char(
			"mu0",
			"mu1",
			"alpha",
			"kappa",
			"sigma",
			"rho",
			"lam0",
			"lam1",
			"muJ",
			"sigJ"
			);
			printf("\n\nSBIL estimation results: rep %d\n", rep);
			prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
			printf("\n\n");

			save(outfile, "thetahats");
		endif
	endif
endfor

if not(MPI_Finalized) MPI_Finalize; endif

