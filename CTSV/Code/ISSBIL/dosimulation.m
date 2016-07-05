% do the simulation for the CTSV model
function data = dosimulation(theta, otherargs);
	n = otherargs{1};
	burnin = otherargs{2};
	M = otherargs{3};
	MM = otherargs{4};
	MMM = otherargs{5};
	[rets, RV5, RV10, BVs, MedRVs, njumps, tjumps, hs, lambda] = CTSVmodel(theta, n, burnin, M, MM, MMM);
	data = [rets, RV5, RV10, BVs, MedRVs];
endfunction

