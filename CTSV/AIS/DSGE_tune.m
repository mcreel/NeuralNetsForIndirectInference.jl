DO_NN = true;
DO_PDM = true;
DO_LOCAL = true;

if DO_LOCAL
    outfile = "tuneLOCAL.out";
else
    outfile = "tunePRIOR.out";
endif

mc_reps = 200; % number of MC reps
nworkers = 25;  % number of worker MPI ranks

SetupAIS;

% design
parameters; % loaded from Common to ensure sync with Gendata
lb = lb_param_ub(:,1);
ub = lb_param_ub(:,3);
prior_params = [lb ub];
theta0 = lb_param_ub(:,2); % original form
nparams = rows(theta0);

setupmpi; % sets comm world, nodes, node, etc.
asbil_theta = theta0; setupdynare; % sets structures and RNG for simulations
load selected;
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
    load simdata.paramspace;
    USERthetaZ = clean_data(simdata);
    % containers
    makebandwidths;
    errors = zeros(mc_reps, nparams,nbw);
    in_ci = zeros(9,nbw);
    rmses = zeros(9,nbw);
    cicoverage = rmses;
endif

for rep = 1:mc_reps
    % the 'true' Zn
    if node==1 % simulate on node1 (can't do it on 0, no *.modfile
        % next line for tuning to true theta0
        %asbil_theta = theta0;
        % next two lines for tuning to draws from prior
        if DO_LOCAL
            if rep==1
                    load tuned_from_prior.out;
            endif
            i = randi(size(thetahatsLL,1));
            asbil_theta = thetahatsLL(i,:)';
        else
            asbil_theta = sample_from_prior();
        endif
        theta0 = asbil_theta;
        ok = false;
        while !ok    
            USERsimulation;
            Zn = aux_stat(data);
            ok = Zn(1,:) != -1000;
        endwhile	
        realdata = data;
        if DO_NN
            Zn = NNstat(Zn');
        else
            Zn = Zn(asbil_selected,:)';    
        endif
        if DO_PDM
            pdm = makepdm(asbil_theta', realdata);
            pdm = pdm - pdm; % for real data, it's zero
            Zn = [Zn pdm];
            n_pdm = size(pdm,2);
        else
            n_pdm = 0;    
        endif 
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
        for bwiter = 1:nbw
            bandwidth = bandwidths(bwiter,:);        
            % now the fit using mean and mediani
            weight = __kernel_normal((Zs-Zn)/bandwidth);
            weight = weight/sum(weight(:));
            % the nonparametric fits, use local linear
            r = LocalPolynomial(thetas, Zs, Zn,  weight, false, 1);
            thetahat = r.mean';
            thetahat = keep_in_support(thetahat); % chop off estimates that go out of support (rare, but happens)
            % now CIs
            % the nonparametric fits, use local linear
            r = LocalConstant(thetas, weight, true);
            %r = LocalPolynomial(thetas, Zs, Zn, weight, true, 1);
            in10 = ((theta0 > r.c') & (theta0 < r.d'));
            in_ci(:,bwiter) = in_ci(:,bwiter) + in10;
            errors(rep,:,bwiter) = (thetahat'- theta0');
            rmse = zeros(9,1);
            if rep > 1
                printf("bandwidth = %f\n", bandwidth);    
                contrib = errors(1:rep,:,bwiter);
                m = mean(contrib);
                s = std(contrib);
                e = contrib;
                b = mean(e);
                e = e.^2;
                mse = mean(e);
                rmse = sqrt(mse);
                clabels = char("bias","rmse");
                rlabels = char(
                "alpha",
                "beta",
                "delta",
                "gam",
                "rho1",
                "sigma1",
                "rho2",
                "sigma2",
                "nss"
                );
                printf("\n\nEstimation results (LL mean): rep %d\n", rep);
                prettyprint([b ; rmse]', rlabels, clabels);
                printf("\n\n");
                toc;
            endif
            rmses(:,bwiter) = rmse;
            cicoverage(:,bwiter) = in_ci(:,bwiter)/rep;
        endfor   
        save(outfile, "bandwidths", "cicoverage", "rmses");
    endif
endfor
if !node
    [junk, bwselect] = min(rmses');
    [junk, bwselectCI] = min(abs(cicoverage'-0.9));
    save SelectedBandwidths bwselect bwselectCI;
end    
if not(MPI_Finalized) MPI_Finalize; endif

