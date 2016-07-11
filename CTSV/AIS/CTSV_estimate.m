DO_NN = true;
DO_PDM = false;
DO_LOCAL = true;

nworkers = 25;  % number of worker MPI ranks

SetupAIS;
setupmpi;

% design
parameters; % loaded from Common to ensure sync with Gendata
lb = lb_ub(1:6,1);
ub = lb_ub(1:6,2);
prior_params = [lb ub];
load Zn20152016;
theta0 = NNstat(Zn')'; # use the NN estimate as true for tuning bandwidths
theta0 = theta0(1:6,:);
nparams = rows(theta0);
setupmpi; % sets comm world, nodes, node, etc.
asbil_theta = theta0; % sets structures and RNG for simulations
selected = ones(size(theta0)); % easy way not to deal with modification
asbil_selected = selected;
MPI_Barrier(CW);

warning ( "off") ;
% number of particles for each node
particles_per_node = floor(nparticles/(nodes-1));

%  frontend: load data and make containers
if !node
    % here, you need to provide code that defines USERthetaZ,
    % which is a reasonably large number set of
    % [theta  Z] where theta is a draw from prior
    % and Z is the output of aux_stat
    load simdata;
    simdata = simdata(:,[1:6 11:end]);   % drop the 4 jump parameters, not identified
    USERthetaZ = clean_data(simdata);
endif

% broadcast true Zn
if node==1 % simulate on node 1
    % we tune to the NN output estimate as true
    asbil_theta = theta0;
    ok = false;
    Zn = theta0';
    n_pdm = 0;    
    realdata = 0; % just a dummy, to use the code
    for i = 2:nodes-1
        MPI_Send(Zn, i, mytag, CW);
        MPI_Send(realdata, i, mytag+1, CW);
    endfor	
    MPI_Send(Zn, 0, mytag, CW);
    MPI_Send(realdata, 0, mytag+1, CW);
    MPI_Send(theta0, 0, mytag+2, CW);
else % receive it on the other nodes
    Zn = MPI_Recv(1, mytag, CW);
    realdata = MPI_Recv(1, mytag+1, CW);
    if  !node
        theta0 = MPI_Recv(1, mytag+2, CW);
    endif    
endif
if DO_PDM % nodes need to know the size
    pdm = makepdm(asbil_theta', realdata);
    n_pdm = size(pdm,2);
else
    n_pdm = 0;    
endif 

MPI_Barrier(CW);    

% call the algorithm that gets AIS particles
if ! node
    tic;
    printf("Starting CreateAIS\n");
endif
CreateAIS; # this gets the particles

% now draw from the AIS density
reps_per_node = round(AISdraws/(nodes-1));
if ! node
    toc;
    printf("Starting SampleFromAIS\n");
    tic;
endif
SampleFromAIS; # this samples from AIS density


% see the results
if !node
    toc;
    printf("Starting fit and CI\n");
    thetas = contribs(:,1:nparams);
    Zs = contribs(:, nparams+1:end);
    test = Zs(:,1) != -1000;
    thetas = thetas(test,:);
    Zs = Zs(test,:);
    stdZ = std(Zs);
    Zs = Zs ./stdZ;
	Zn = Zn./stdZ;
 
    % loop over bandwidths: they go from 0.001 to 10, quadratically
    makebandwidths;
    load SelectedBandwidths; # these come from most recent run of DSGE_tune.m
    bandwidthsCI = bandwidths(bwselectCI,:);
    bandwidths = bandwidths(bwselect,:);
    
    thetahat = zeros(nparams,1);
    lowerCI = zeros(nparams,1);
    upperCI = zeros(nparams,1);
    % now the fit using mean and median
    for i = 1:nparams
        bandwidth = bandwidths(i,:);
        weight = __kernel_normal((Zs-Zn)/bandwidth);
        weight = weight/sum(weight(:));
        % the nonparametric fits, use local linear
        r = LocalPolynomial(thetas, Zs, Zn,  weight, false, 1);
        thetahat(i,:) = r.mean(:,i);
        thetahat = keep_in_support(thetahat); % chop off estimates that go out of support (rare, but happens)
        % now CIs
        bandwidth = bandwidthsCI(i,:);
        weight = __kernel_normal((Zs-Zn)/bandwidth);
        weight = weight/sum(weight(:));
        % the nonparametric fits, use local linear
        r = LocalConstant(thetas, weight, true);
        lowerCI(i,:) = r.c(:,i);
        upperCI(i,:) = r.d(:,i);
    endfor
save CTSV_estimate.out thetahat lowerCI upperCI;    
thetahat
lowerCI
upperCI
endif
if not(MPI_Finalized) MPI_Finalize; endif

