load tuned_from_prior.out;
parameters;
theta0 = lb_param_ub(:,2);
rep = rows(thetahatsLC);

contrib = thetahatsLC(1:end,:);
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
"alpha",
"beta",
"delta",
"gam",
"rho1",
"sigma1",
"rho2",
"sigma2",
"nss"
);
printf("\n\nEstimation results (LC mean): rep %d\n", rep);
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");
% now median
contrib = thetahatsLC50(1:end,:);
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
"alpha",
"beta",
"delta",
"gam",
"rho1",
"sigma1",
"rho2",
"sigma2",
"nss"
);
printf("\n\nEstimation results (LC median): rep %d\n", rep);
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");
contrib = thetahatsLL(1:end,:);
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
"alpha",
"beta",
"delta",
"gam",
"rho1",
"sigma1",
"rho2",
"sigma2",
"nss"
);
printf("\n\nEstimation results (LL mean): rep %d\n", rep);
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");
% now median
contrib = thetahatsLL50(1:end,:);
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
"alpha",
"beta",
"delta",
"gam",
"rho1",
"sigma1",
"rho2",
"sigma2",
"nss"
);
printf("\n\nEstimation results (LL median): rep %d\n", rep);
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");
contrib = thetahatsLQ(1:end,:);
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
"alpha",
"beta",
"delta",
"gam",
"rho1",
"sigma1",
"rho2",
"sigma2",
"nss"
);
printf("\n\nEstimation results (LQ mean): rep %d\n", rep);
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");
% now median
contrib = thetahatsLQ50(1:end,:);
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
"alpha",
"beta",
"delta",
"gam",
"rho1",
"sigma1",
"rho2",
"sigma2",
"nss"
);
printf("\n\nEstimation results (LQ median): rep %d\n", rep);
prettyprint([theta0'; m; priormean; s; priorsdev; b ; priorbias; rmse; priorrmse]', rlabels, clabels);
printf("\n\n");
printf("90%% CI coverage: \n");
in_ci = (cilower <= theta0') & (ciupper >= theta0');
disp(mean(in_ci));
printf("\n");

