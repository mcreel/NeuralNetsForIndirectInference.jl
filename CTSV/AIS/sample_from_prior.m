function theta_s = sample_from_prior()
		parameters;
        lb = lb_ub(1:6,1);
        ub = lb_ub(1:6,2);
        theta_s = rand(size(ub)).*(ub-lb) + lb;
endfunction


