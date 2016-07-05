1;

% this function should generate a draw from the prior,
% taking the prior parameters as the only argument
function theta_s = sample_from_prior(prior_params)
	lb = prior_params(:,1);
	ub = prior_params(:,2);
	theta_s = rand(size(ub)).*(ub-lb) + lb;
endfunction

% generates a draw from neighborhood of particle
function theta_s = sample_from_particles(particles, delta)
	i = randi(rows(particles));
	j = randi(columns(particles));
	theta_s = particles(i,:);
    theta_s(:,j) = theta_s(:,j) + delta(:,j)*randn(1,1);
	theta_s = theta_s';
endfunction

% check support conditions: reflect back in if outside
function theta = insupport(theta, support_limits)
	lb = support_limits(:,1);
	ub = support_limits(:,2);
	theta = (2*ub-theta).*(theta > ub) + theta.*(theta < ub);
	theta = (2*lb-theta).*(theta < lb) + theta.*(theta > lb);
endfunction


% does some recombination
function newparticles = mutate(particles)
	% put in random order
	a = rand(rows(particles),1);
	[junk, a] = sort(a);
	particles = particles(a,:);
	% these don't mutate
	particles1 = particles(1:floor(rows(particles)/2),:);
	% these ones mutate
	particles2 = particles(1:ceil(rows(particles)/2),:);
	newparticles = zeros(size(particles2));
	for i = 1:columns(particles)
		a = rand(rows(particles2),1);
		[junk, a] = sort(a);
		newparticles(:,i) = particles2(a, i);
	endfor
	newparticles = [newparticles; particles1];
endfunction	


function particles = select_particles(Zn, contribs, fraction, common=true, mutation=false, stdZ)
	dimZ = columns(Zn);
	dimTheta = columns(contribs)-dimZ;
	particles = contribs(:,1:dimTheta);
	Zs = contribs(:,dimTheta+1:end);
	Z = [Zn; Zs];
    q = quantile(Z,0.99);
	test = Z < q;
    Z = test.*Z + (1-test).*q;
	q = quantile(-Z,0.99);
	test = -Z < q;
	Z = test.*Z - (1-test).*q;
    Z = Z./stdZ;


%	[Z, m, s] = st_norm(Z);
	Zn = Z(1,:);
	Zs = Z(2:end,:);
	k = ceil(fraction*rows(contribs));
	newparticles = zeros(k, columns(particles));

%	if common
		% parameters selected using common stat
		load selected;
        s = selected;
		Zs1 = Zs(:,s);
		Zn1 = Zn(:,s);
		% add sampling in inverse proportion to distance?
		[idx dist] = nearest_neighbors(Zn1, Zs1, k);
		newparticles = particles(idx,:); % the best particles for these stats
 #{
            else
		% parameters selected using separate stats
	    load selectedISBIL;
		for i = 1:dimTheta
			s = selected{i};
			Zs1 = Zs(:,s);
			Zn1 = Zn(:,s);
			[idx dist] = nearest_neighbors(Zn1, Zs1, k);
			newparticles(:,i) = particles(idx,i); % the best particles for these stats
		endfor
	endif
#}
	particles = newparticles;
	if mutation particles = mutate(particles); endif
endfunction

