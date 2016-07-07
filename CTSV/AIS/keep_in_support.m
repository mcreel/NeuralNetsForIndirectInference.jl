function theta = keep_in_support(theta)
		s = size(theta);
        theta = theta(:);
        parameters;
        lb = lb_ub(1:6,1);
        ub = lb_ub(1:6,2);
        theta = max(theta,lb+eps);
        theta = min(theta,ub-eps);
        theta = reshape(theta,s);
endfunction


