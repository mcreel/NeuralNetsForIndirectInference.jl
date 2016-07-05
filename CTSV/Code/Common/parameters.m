% the "true" values are the 2008-2011 estimates from the JEF paper
#{
# all
lb_ub = [
-0.1    0.1     % mu0
-0.1    0.1     % mu1
-3      3       % alpha
0       0.5     % kappa
0       1       % sigma_h
-1      0       % rho
0       0.1     % lam0
0       3       % lam1
-0.05   0.05    % mu_j
0.0     5       % sig_j
0       0       % sig_eps 
];
#}

# no jumps
lb_ub = [
-0.1    0.1     % mu0
-0.1    0.1     % mu1
-3      3       % alpha
0       0.5     % kappa
0       1       % sigma_h
-1      0       % rho
0       0       % lam0
0       0       % lam1
0       0       % mu_j
0.0     0       % sig_j
0       0       % sig_eps 
];

