%temp_theta = parameterize(asbil_theta, lb, ub);
temp_theta = asbil_theta;
alpha = temp_theta(1,:);
beta  = temp_theta(2,:);
delta = temp_theta(3,:);
gam   = temp_theta(4,:);
rho1   = temp_theta(5,:);
sigma1 = temp_theta(6,:);
rho2   = temp_theta(7,:);
sigma2 = temp_theta(8,:);
nss   = temp_theta(9,:);

% pass values to Dynare
set_param_value('alppha', alpha);
set_param_value('betta', beta);
set_param_value('delta', delta);
set_param_value('gam', gam);
set_param_value('rho1', rho1);
set_param_value('sigma1', sigma1);
set_param_value('rho2', rho2);
set_param_value('sigma2', sigma2);
set_param_value('nss', nss);

% do the simulation at the param values
info = stoch_simul(var_list_);
% get a simulation of length 160 (40 years quarterly), and compute aux. statistic
data = [y c n MPK MPL];
data = data(101:260,:);
