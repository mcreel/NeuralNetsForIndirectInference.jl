function theta_s = sample_from_prior()
		parameters;
        lb = lb_param_ub(:,1);
        ub = lb_param_ub(:,3);
        theta_s = rand(size(ub)).*(ub-lb) + lb;
endfunction


