% controls for creating the adaptive importance sampling density
iters = 8;
initialparticles = nworkers*round(300/nworkers); % number to take from sample from prior
nparticles = nworkers*round(300/nworkers); % number per round
particlequantile = 20; % keep the top % of particles
verbose = false;
% controls for drawing the final sample from mixture of AIS and prior
mixture = 0.2; % proportion sampled from original prior 
AISdraws = nworkers*round(5000/nworkers); # number of draws from final AIS density


