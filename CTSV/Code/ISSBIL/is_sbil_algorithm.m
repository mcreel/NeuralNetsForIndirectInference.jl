% main algorithm code, kept in one place to ensure Monte Carlo and estimation are doing the same thing
if node
	for iter = 1:iters-1;	
		% intermediate rounds: sample from mixture
		particles = MPI_Recv(0, mytag, CW); % get the initial particles
		delta = MPI_Recv(0, mytag+1, CW); % receive delta
		mixture = MPI_Recv(0, mytag+2, CW); % receive delta
		stdZ = MPI_Recv(0, mytag+3, CW); % receive delta
		first_time = true;
		for i = 1:particles_per_node
		if rand < mixture 
				theta = sample_from_prior(prior_params);
			else	
				theta = sample_from_particles(particles, delta);
			endif
			theta = insupport(theta, prior_params);
			data = dosimulation(theta, otherargs);
			Z = aux_stat(data);
			if Z(1,:) != -1000
				contrib = [theta' Z'];
				if first_time
					contribs = contrib;
					first_time = false;
				else	
					contribs = [contribs; contrib];
				endif
			endif
		endfor
		contribs = clean_data(contribs);
		particles = select_particles(Zn, contribs, keep_fraction, true, true, stdZ);
		MPI_Send(particles, 0, mytag, CW);
	endfor

	% last round: increase number of particles sampled
	%particles = MPI_Recv(0, mytag, CW); % get the initial particles
	%delta = MPI_Recv(0, mytag+1, CW); % receive delta
	%mixture = MPI_Recv(0, mytag+2, CW); % receive delta
	first_time = true;
	for i = 1:particles_per_node2
		if rand < mixture 
			theta = sample_from_prior(prior_params);
		else	
			theta = sample_from_particles(particles, delta);
		endif
		theta = insupport(theta, prior_params);
		data = dosimulation(theta, otherargs);
		Z = aux_stat(data);
		if Z(1,:) != -1000
			contrib = [theta' Z'];
			if first_time
				contribs = contrib;
				first_time = false;
			else	
				contribs = [contribs; contrib];
			endif
		endif
	endfor
	contribs = clean_data(contribs);
	MPI_Send(contribs, 0, mytag, CW);
else % frontend
    dimTheta = columns(simdata)-columns(Zn);    
    Z = simdata(:,dimTheta+1:end);
   	q = quantile(Z,0.99);
	test = Z < q;
    Z = test.*Z + (1-test).*q;
	q = quantile(-Z,0.99);
	test = -Z < q;
	Z = test.*Z - (1-test).*q;
    stdZ = std(Z);    
	particles = select_particles(Zn, simdata, 0.005, false, true, stdZ); % take 5 in a 1000, use individual stats 
	mixture = 0; % weight on prior	
	for iter = 1:iters-1	
		% send particles, delta and mixture to all nodes
		delta = iter/iters*std(particles);
        for i = 1:nodes-1
			MPI_Send(particles, i, mytag, CW);
			MPI_Send(delta, i, mytag+1, CW);
			MPI_Send(mixture, i, mytag+2, CW);
			MPI_Send(stdZ, i, mytag+3, CW);
		endfor
		oldparticles = particles;
		% receive selected particles from nodes
		for i = 1:nodes-1
			contrib = MPI_Recv(i, mytag, CW);
			if (i == 1)
				particles = contrib;	
			else
				particles = [particles; contrib];
			endif
		endfor
		if verbose dstats(particles); endif
		% stability statistic: should converge to a small number 
		temp = particles;
		test = std(temp) != 0;
		temp = temp(:,test);
		temp2 = oldparticles(:,test);
		change = mean(temp)- mean(temp2);
		V = cov(temp);
		stable = change*inv(V)*change';
		pvalue = 1-chi2cdf(stable, rank(V));
		if verbose printf("test for stability: statistic: %f  p-value: %f\n", stable, pvalue); endif
	endfor
	% receive final particles and statistics from nodes
	for i = 1:nodes-1
		contrib = MPI_Recv(i, mytag, CW);
		if (i == 1)
			contribs = contrib;	
		else
			contribs = [contribs; contrib];
		endif
	endfor
endif


