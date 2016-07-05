n = 349;  % sample size: the 2015-2016 data has 349 obsns.
reps = 600000;
n_pooled = 1000;   % number of runs accumulated before sent from nodes to frontend
outfile = "simdata.paramspace";


verbose = 1;
delta = 5; % time delta in minutes
M = 24*60/delta; % number of delta minute periods in a 24 hour day 
MM = 6.5*60/delta; % number of delta minute periods in 5.5 hour trading day (S&P500 has 5.5 hour long trading period)
MMM = 1; % number of periods between RV contributions. The SP500 data uses 5 minute intervals, so we want delta*MMM=5
burnin = 200; % burnin in days


% parameters
parameters; % loaded in from common file to synchronize
lb = lb_ub(:,1);
ub = lb_ub(:,2);

if not(MPI_Initialized) MPI_Init; endif
CW = MPI_Comm_Load("NEWORLD");
node = MPI_Comm_rank(CW);
nodes = MPI_Comm_size(CW);
mytag = 48;


###############################################################################
############## you do not need to alter anything below this line ##############
###############################################################################


if node
	more_please = 1;
	while more_please
		# break it up to do intermediate writes
		for j = 1:n_pooled
            % draw from prior and check bounds
			model_params = lb + (ub - lb).*rand(size(lb));
			% the aux stat
			[rets, RV5, RV10, BVs, MedRVs, njumps, tjumps, hs, lambda] = CTSVmodel(model_params, n, burnin, M, MM, MMM);
			Z = aux_stat([rets, RV5, BVs]);
			Z = Z';
			contrib = [model_params' Z];
			if (j==1) contribs = zeros(n_pooled, columns(contrib)); endif
			contribs(j,:) = contrib;
		endfor
		MPI_Send(contribs, 0, mytag, CW);
		# check if we're done
		if (MPI_Iprobe(0, mytag+1, CW))
			junk = MPI_Recv(0, mytag+1, CW);
			break;
		endif
	endwhile
	
else % frontend
	received = 0;
	done = false;
	while received < reps
		% retrieve results from compute nodes
		%pause(0.01);
		for i = 1:nodes-1
			% compute nodes have results yet?
			ready = false;
			ready = MPI_Iprobe(i, mytag, CW); % check if message pending
			if ready
				% get it if it's there
				contribs = MPI_Recv(i, mytag, CW);
				need = reps - received;
				received = received + n_pooled;
				% truncate?
				if n_pooled  >= need
						contribs = contribs(1:need,:);
						done = true;
				end

				% write to filw
				FN = fopen (outfile, "a");
				if (FN < 0) error ("make_simdata: couldn't open output file %s", outfile); endif
	
				for j = 1:rows(contribs)
					fprintf(FN, "%f ", contribs(j,:));
					fprintf(FN, "\n");
				endfor
				fclose(FN);
				%system('sync');

				if verbose
					printf("\nContribution received from node%d.  Received so far: %d\n", i, received);
				end
				if done
					% tell compute nodes to stop loop
					for i = 1:(nodes-1)
						MPI_Send(" ",i, mytag,CW); % send out message to stop
						ready = MPI_Iprobe(i, mytag, CW); % get last messages
						if ready contribs = MPI_Recv(i, mytag, CW); end
					end
					break;
				end
			end
		end
	end
end
if not(MPI_Finalized) MPI_Finalize; end     

