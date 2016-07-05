function d = clean_data(simdata)
%	printf("%d rows read in\n", rows(simdata));
	test = any(isnan(simdata'));
	test = (test ==0);
	simdata = simdata(test,:);
	test = any(isinf(simdata'));
	test = (test ==0);
	simdata = simdata(test,:);
%	printf("%d valid rows \n", rows(simdata));

	% bad data
	test = simdata(:,12) !=  -1000;
	simdata = simdata(test,:);
%	printf("%d after general bad data\n", rows(simdata));
	d = simdata;
end
