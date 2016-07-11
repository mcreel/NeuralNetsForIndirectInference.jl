function theta = keep_in_support(theta)
		s = size(theta);
        theta = theta(:);
        parameters;
        lb = lb_ub(1:6,1);
        ub = lb_ub(1:6,2);
        theta = max(theta,lb);
        theta = min(theta,ub);
        theta = reshape(theta,s);
endfunction


