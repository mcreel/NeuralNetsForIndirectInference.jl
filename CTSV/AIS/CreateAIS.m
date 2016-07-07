## Copyright (C) 2014 Michael Creel
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Author: Michael Creel <michael@pelican>
## Created: 2014-10-22

%% this is the main asbil algorith code, now in one place for synchronization

% first define functions, then the main algorithm
1;

function theta_s = sample_from_particles(particles, delta, lb, ub)
	i = randi(rows(particles));
	j = randi(columns(particles));
	theta_s = particles(i,:);
	ok = false;
	while !ok
		trial = theta_s;
       	trial(:,j) = trial(:,j) + delta(:,j).*randn();
		ok = all(trial >= lb(1:6,:)') & all(trial <= ub(1:6,:)');
	endwhile	
	theta_s = trial';
endfunction

% selection
function [particles, dist] = select_particles(Zn, oldparticles, newparticles, nparticles, scale)
	dimZ = columns(Zn);
    dimTheta = columns(oldparticles)-dimZ;
	particles = [oldparticles; newparticles];
    Zs = particles(:,dimTheta+1:end);
	Z = [Zn; Zs];
    Z = Z./scale;
    Zn = Z(1,:);
	Zs = Z(2:end,:);
	[idx, dist]  = nearest_neighbors(Zn, Zs, nparticles);
	particles = particles(idx,:); % the best particles for these stats
endfunction

% main algorithm code, kept in one place to ensure Monte Carlo and estimation are doing the same thing
if node
	for iter = 1:iters;	
		% intermediate rounds: sample from mixture
		particles = MPI_Recv(0, mytag, CW); % get the full set of particles
		asbil_thetas = particles(:,1:nparams);

		% search breadth: damp initial rounds for stability
        if iter < 3
			particle_sd = iter/iters*std(asbil_thetas);
		else
			particle_sd = std(asbil_thetas);
		endif
		
		contribs = zeros(particles_per_node, columns(particles));
		for i = 1:particles_per_node
			ok = false;
			% select until we get a good simulation: notice, some regions
			% of prior may generate bad sims, and be undersampled. This is
			% ignored for now
			while !ok
                asbil_theta = sample_from_particles(asbil_thetas, particle_sd, lb, ub);
                USERsimulation; % requires 'asbil_theta', and perhaps
			    % other things to be defined, generates 'data'
				Z = aux_stat(data);
                if Z(1,:) != -1000  % this is the code for bad simulation results
					ok = true;
				    if DO_NN
                        Z = NNstat(Z');
                    else    
				        Z = Z(asbil_selected,:)';
                    endif 
                    if DO_PDM
                        %pdm = makepdm(asbil_theta', data) - makepdm(asbil_theta', realdata);
                        pdm = makepdm(asbil_theta', realdata);
                        Z = [Z pdm];
                    endif 
					contribs(i,:) = [asbil_theta' Z];
				endif
			endwhile	
		endfor
		MPI_Send(contribs, 0, mytag, CW); % send selected to frontend, to sync across nodes
	endfor
else % frontend
    % the initial particles from large sample from prior
    thetas = USERthetaZ(:,1:nparams);
	Zs = USERthetaZ(:,nparams+1:end);
    if DO_NN
        Zs = NNstat(Zs);
    else
        Zs = Zs(:,asbil_selected);
    endif
    scale = std(Zs);
    if DO_PDM
        pdm = 0.00000001*randn(rows(Zs),n_pdm); % start with noise
        Zs = [Zs pdm];
        scale = [scale ones(1, n_pdm)]; % large scale means pdm irrelevant here
    endif
	particles = [thetas Zs];
	[particles, dist] = select_particles(Zn, particles(1:end-1,:), particles(end,:), initialparticles, scale);
    %scale = [std(particles(:,nparams+1:end-n_pdm)) ones(1,n_pdm)];
    for iter = 1:iters	
		% send particles to all nodes
		for i = 1:nodes-1
			MPI_Send(particles, i, mytag, CW);
		endfor
		% receive new particles from nodes
		for i = 1:nodes-1
			contrib = MPI_Recv(i, mytag, CW);
			if (i == 1)
				particles = contrib;	
			else
				particles = [particles; contrib];
			endif
		endfor
        if iter < iters
            keep = ceil(nparticles*particlequantile/100);
            if iter == 1
                oldparticles = particles(1,:);
                scale = std(particles(:,nparams+1:end));
            endif
	        [particles, dist] = select_particles(Zn, oldparticles, particles, keep, scale);
        endif
		if verbose
			printf("Iteration %d\n", iter);
            printf("average distance: %f\n", mean(dist));
			dstats(particles(:,1:nparams));
		endif
		% stability statistic: should converge to a small number 
		change = abs(mean(particles(:,1:nparams))-mean(oldparticles(:,1:nparams)));
		stable = sum(change);
		if verbose printf("test for stability: statistic: %f\n", stable); endif
	endfor
endif


