parameters;
theta0 = lb_param_ub(:,2);
lb = lb_param_ub(:,1);
ub = lb_param_ub(:,3);
priormean = (ub+lb)'/2;
priorsdev = sqrt(((ub-lb).^2)/12);
priorsdev = priorsdev';
priorbias = priormean - theta0';
priorrmse = sqrt(priorbias.^2 + priorsdev.^2);


load ./NN1PDM1_1000/tuned_local.out;
contrib = thetahatsLL;
m = mean(contrib);
s = std(contrib);
e = contrib - repmat(theta0',rows(contrib),1);
b = mean(e);
e = e.^2;
mse = mean(e);
rmse = sqrt(mse);
relb = b ./ theta0';
relrmse = rmse ./ theta0';
format('bank');
100*relb'
100*mean(abs(relb))'
100*relrmse'
100*mean(relrmse)'

