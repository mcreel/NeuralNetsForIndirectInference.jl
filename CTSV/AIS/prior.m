function d = prior(theta)

        # define support
        lb_ub = [
        0.20   	0.4		% alpha
        0.95    0.995	% beta
        0.01    0.1		% delta
        0.0	    5		% gam
        0    	0.99	% rho1
        0       0.1		% sigma1
        0    	0.99    % rho2
        0.00	0.1		% sigma2
        6/24    9/24	% nss
        ];

        lb = lb_ub(:,1)';
        ub = lb_ub(:,2)';
        d = all((theta >= lb) & (theta <= ub),2) ./prod(ub-lb);

endfunction

