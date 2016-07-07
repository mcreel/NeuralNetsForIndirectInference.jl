function Z = aux_stat(data)
	bad_data = false;
	% check for bad inputs
	if (sum(any(isnan(data)))||sum(any(isinf(data)))||sum(any(std(data)==0)))
		Z = -1000*ones(56,1);
	else
		rets = data(:,1);
		RV = data(:,2);
		BV = data(:,3);
		jumps = RV - BV;
		RV= RV.*(RV>0);		
		BV= BV.*(BV>0);		
		jumps = jumps.*(jumps>0);		

		% bound data
		test = rets > 1000;
		rets = test*1000+ (1-test).*rets;
		test = rets < -1000;
		rets = test*(-1000)+ (1-test).*rets;

		% bound data
		test = RV > 10000;
		RV = test*10000+ (1-test).*RV;
		test = BV > 10000;
		BV = test*10000+ (1-test).*BV;
		test = jumps > 10000;
		jumps = test*10000+ (1-test).*jumps;

		% detect jumps
		test1 = abs(jumps);
		s = std(test1);
		test1 = test1 < 2.5*s;
		test2 = abs(log(jumps));
		s = std(test2);
		test2 = test2 < 2.5*s;
		test = test1 | test2;
		rets2 = rets.*test; % if jump, sets to zero
		test = 1-test;
		Z = mean(test); % good for lam0
		m = sum(lags(test,10),2)/10; % average of detector over 10 lags
		temp = [test, m];
		temp = temp(11:end,:);
		z = corr(temp);
        z = z(1,2);
        Z = [Z; z];
		
		% use logs
		BV = log(BV);
		RV = log(RV);
		
		% basic stats
		data = [rets rets2 RV BV jumps];
		z = dstats(data, 0, true);
		z = z(:,1:4);
		z = z(:);
		Z = [Z; z]; % means, sd, skew + kurt
		
		% correlations
		c = corr(data);
		c = triu(c,1);
		c = vec(c);
		c = c(c !=0);
		Z = [Z; c];

		% demean, so constants not needed (they are in dstats, above)
		data = st_norm(data);
		
		if (sum(any(isnan(data)))||sum(any(isinf(data)))||sum(any(std(data)==0)))
			bad_data = true;
		else
			rets = data(:,2);
			RV = data(:,3);
			BV = data(:,4);
			jumps = data(:,5);

			% BV on 2 lags of MA, and jumps: rate of decline of coefs of MAs should be good for kappa
			temp = [BV lags(BV, 4)];
			temp = temp(5:end,:);
			y = temp(:,1);
			x = [sum(temp(:,2:3),2)/2 sum(temp(:,3:4),2)/2] ;
			[z, junk, junk, ess, rsq] = mc_ols(y,x,"", true);
			z = [z; z(2,:)/z(1,:)];
			sig = sqrt(ess/(rows(x)-columns(x)));
			Z = [Z; z; sig; rsq];
			
			% jumps
			temp = [jumps lags(BV,1) lags(jumps, 10)];
			temp = temp(11:end,:);
			y = temp(:,1);
			x = [temp(:,2) sum(temp(:,3:end),2)/10];
			[z, junk, e_jump, ess, rsq] = mc_ols(y,x,"", true);
			sig = sqrt(ess/(rows(x)-columns(x)));
			Z = [Z; z; sig; rsq];

			% for kappa and sig
			temp = [BV lags(BV,1) lags(rets,1)];
			temp = temp(11:end,:);
			y = temp(:,1);
			x = temp(:,2:end);
			x = [x x.*x];
			[z, junk, e_BV, ess, rsq] = mc_ols(y,x,"", true);
			sig = sqrt(ess/(rows(x)-columns(x)));
			Z = [Z; z; sig; rsq];

			% rets
			temp = [rets lags(rets,1) lags(BV,1)] ;
			temp = temp(11:end,:); % use same as above to have same number of obs, to calculate corr
			y = temp(:,1);
			x = temp(:,2:end);
			x = [x x.*x];
			[z, junk, e_ret, ess, rsq] = mc_ols(y,x,"", true);
			sig = sqrt(ess/(rows(x)-columns(x)));
			Z = [Z; z; sig; rsq];

		    % error correlations
            z = triu(corr([e_ret e_jump e_BV]),1);
            z = z(:);
		    z = z(z !=0);
			Z = [Z; z];
		endif
		if (sum(any(isnan(Z)))||sum(any(isinf(Z))))
			Z = -1000*ones(56,1);
		endif
	endif
endfunction
