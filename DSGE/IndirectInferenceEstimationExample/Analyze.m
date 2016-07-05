% set true parameters here
alpha  = 0.33;
beta   = 0.99;
delta  = 0.025;
gam    = 2;
rho1   = 0.9;
sigma1 = 0.02;
rho2   = 0.7;
sigma2 = 0.01;
nss    = 1/3;
theta0 = [alpha; beta; delta; gam; rho1; sigma1; rho2; sigma2; nss];

load IndirectInferenceResults.out;
directNN = IndirectInferenceResults(:,2:10);
II = IndirectInferenceResults(:,11:19);
se = IndirectInferenceResults(:,20:end);

contrib = directNN;
m = mean(contrib);
s = std(contrib);
e = contrib - repmat(theta0',rows(contrib),1);
b = mean(e);
b  = 100*b./theta0';
e = e.^2;
mse = mean(e);
rmse = sqrt(mse);
rmse = 100*rmse./theta0';
mae = mean(abs(e));
clabels = char("true", "mean", "sdev.", "%bias","%rmse");
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
printf("\n\nEstimation results: Direct NN estimator\n");
prettyprint([theta0'; m; s; b ; rmse]', rlabels, clabels);
printf("\n\n");


contrib = II;
m = mean(contrib);
s = std(contrib);
e = contrib - repmat(theta0',rows(contrib),1);
b = mean(e);
b = 100*b./theta0';
e = e.^2;
mse = mean(e);
rmse = sqrt(mse);
rmse = 100*rmse./theta0';
mae = mean(abs(e));
clabels = char("true", "mean", "sdev.", "%bias","%rmse");
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
printf("\n\nEstimation results: II estimator\n");
prettyprint([theta0'; m; s; b ; rmse]', rlabels, clabels);
printf("\n\n");


inci = (contrib - se*1.645 < theta0') & (contrib + 1.645*se > theta0');
printf("CI coverage\n");
disp(mean(inci)');

