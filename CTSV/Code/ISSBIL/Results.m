%load ResultsNoME;
load bootstrap.postcrisis;
contrib = thetahats;
parameters;
theta0 = lb_param_ub(:,2);
m = mean(contrib);
s = std(contrib);
e = contrib - repmat(theta0',rows(contrib),1);
b = mean(e);
e = e.^2;
mse = mean(e);
rmse = sqrt(mse);
lb = lb_param_ub(:,1);
ub = lb_param_ub(:,3);
priormean = (ub+lb)'/2;
priorsdev = sqrt(((ub-lb).^2)/12);
priorsdev = priorsdev';
priorbias = priormean - theta0';
priorrmse = sqrt(priorbias.^2 + priorsdev.^2);
mae = mean(abs(e));
clabels = char("true", "mean", "pmean", "sdev.","psdev", "bias", "pbias","rmse", "prmse");
rlabels = char(
"mu0",
"mu1",
"alpha",
"kappa",
"sigma",
"rho",
"lam0",
"lam1",
"muJ",
"sigJ",
"sige"
);
printf("\n\nSBIL estimation results\n");
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");


