% This code does indirect inference estimation of the simple DSGE model
dovarcov = true;
writeoutput = true;
MonteCarloReps = 100;
obj_tol = 1e-8;
S = 50; % number of simulations to compute Ehat(Zs)

%{
Set the true parameters within these bounds
   Lower     Upper 
   0.20000   0.40000
   0.95000   1.00000
   0.01000   0.10000
   0.00000   5.00000
   0.00000   1.00000
   0.00000   0.10000
   0.00000   1.00000
   0.00000   0.10000
   0.25000   0.37500
%}
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

% set up simulation of the model using Dynare
save parameterfile  alpha beta delta gam rho1 sigma1 rho2 sigma2 nss;
dynare SimpleModel noclearall;
% get draw of statistic at true parameter values
RNGstate = tic; % this sets different seed each time
toc;

for mcrep = 1:MonteCarloReps
    set_dynare_seed(RNGstate + mcrep);  % need to bump this here, because
                                        % below, state is fixed to control chatter
    % do the simulation at the true param values
    % need to re-set for every MC rep, as they are changed, below
    % break into pieces
    alpha = theta0(1,:);
    beta  = theta0(2,:);
    delta = theta0(3,:);
    gam   = theta0(4,:);
    rho1   = theta0(5,:);
    sigma1 = theta0(6,:);
    rho2   = theta0(7,:);
    sigma2 = theta0(8,:);
    nss   = theta0(9,:);
    % the psi implied by other parameters
    c1 = ((1/beta + delta - 1)/alpha)^(1/(1-alpha));
    kss = nss/c1;
    css = kss * (c1^(1-alpha) - delta);
    c2 = (css)^(-gam/alpha);
    psi = (1-alpha)*((c1/c2)^(-alpha));
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
    ok = false;
    while !ok
        info = stoch_simul(var_list_);
        % get a simulation of length 160 and compute aux. statistic
        data = [y c n MPK MPL];
        data = data(101:260,:);
        Z = aux_stat(data);
        ok = Z(1,1) != -1000;
    end
    Zn = NNstat(Z');
    Zn(:,6) = abs(Zn(:,6)); % st. devs posititive for identification
    Zn(:,8) = abs(Zn(:,8)); 

    % get RNG state to control chatter
    RNGstate = 1234;
    % start II loop here
    theta = Zn'; % use the NN estimate as start value
    obj_value = 100;
    iters = 0;
    while (obj_value > obj_tol) && (iters < 100);
        iters = iters + 1;
        dimTheta = rows(theta);
        D = zeros(dimTheta, dimTheta);
        for kk = 0:dimTheta % first time for fn, others for derivatives
            set_dynare_seed(RNGstate);
            % do the simulation at the param values
            if kk >0
                p = theta(kk,:);    
                SQRT_EPS = sqrt(eps);
                diff = exp(log(eps)/3);
                test = (abs(p) + SQRT_EPS) * SQRT_EPS > diff;
                if (test)
                    dd = (abs(p) + SQRT_EPS) * SQRT_EPS;
                else
                    dd = diff;
                end
                theta(kk,:) = theta(kk,:) + dd;
            end   
            % simulate at param values
            alpha = theta(1,:);
            beta  = theta(2,:);
            delta = theta(3,:);
            gam   = theta(4,:);
            rho1   = theta(5,:);
            sigma1 = theta(6,:);
            rho2   = theta(7,:);
            sigma2 = theta(8,:);
            nss   = theta(9,:);
            c1 = ((1/beta + delta - 1)/alpha)^(1/(1-alpha));
            kss = nss/c1;
            css = kss * (c1^(1-alpha) - delta);
            c2 = (css)^(-gam/alpha);
            psi = (1-alpha)*((c1/c2)^(-alpha));
            set_param_value('alppha', alpha);
            set_param_value('betta', beta);
            set_param_value('delta', delta);
            set_param_value('gam', gam);
            set_param_value('rho1', rho1);
            set_param_value('sigma1', sigma1);
            set_param_value('rho2', rho2);
            set_param_value('sigma2', sigma2);
            set_param_value('nss', nss);
            E_Z = Zn-Zn;
            for s = 1:S
                ok = false;
                while !ok
                    % do the simulation at the param values
                    info = stoch_simul(var_list_);
                    % get a simulation of length 160 and compute aux. statistic
                    data = [y c n MPK MPL];
                    data = data(101:260,:);
                    Z = aux_stat(data);
                    ok = Z(1,1) != -1000;
                end  
                Z = NNstat(Z');
                E_Z = E_Z + Z/S;
            end
            m = Zn-E_Z;
            m = m';
            if kk == 0
                m0 = m;
                obj_value = m'*m;
                obj_value
            else
                theta(kk,:) = theta(kk,:) - dd; % set back to unperturbed
                D(kk,:) = (m' - m0') / dd; % compute forward diff. gradient 
            end
        end
        theta = theta - 0.8*D'*m0; % for some reason, D' works better
        theta(6,:) = abs(theta(6,:));
        theta(8,:) = abs(theta(8,:));
        obj_value
    end

    if dovarcov
        % simulations from dynare, at last param value
        alpha = theta(1,:);
        beta  = theta(2,:);
        delta = theta(3,:);
        gam   = theta(4,:);
        rho1   = theta(5,:);
        sigma1 = theta(6,:);
        rho2   = theta(7,:);
        sigma2 = theta(8,:);
        nss   = theta(9,:);
        c1 = ((1/beta + delta - 1)/alpha)^(1/(1-alpha));
        kss = nss/c1;
        css = kss * (c1^(1-alpha) - delta);
        c2 = (css)^(-gam/alpha);
        psi = (1-alpha)*((c1/c2)^(-alpha));
        set_param_value('alppha', alpha);
        set_param_value('betta', beta);
        set_param_value('delta', delta);
        set_param_value('gam', gam);
        set_param_value('rho1', rho1);
        set_param_value('sigma1', sigma1);
        set_param_value('rho2', rho2);
        set_param_value('sigma2', sigma2);
        set_param_value('nss', nss);
        R = 200;
        vc_reps = zeros(R,dimTheta);
        for r = 1:R
            info = stoch_simul(var_list_);
            % get a simulation of length 160 and compute aux. statistic
            data = [y c n MPK MPL];
            data = data(101:260,:);
            Z = aux_stat(data);
            Z = NNstat(Z');
            vc_reps(r,:) = Z;
        end
        Omega = (1+1/S)*cov(vc_reps); % 1 for Zn, 1/S for the average
        Dinv = inv(D);
        VC = Dinv'*Omega*Dinv;
        se = sqrt(diag(VC));
        se'
        inci = ((theta - 1.645*se) < theta0) & ((theta + 1.645*se) > theta0);
        inci'
    else
        se = theta-theta;    
    end   
    converge = obj_value < obj_tol;
    temp = [converge Zn theta' se'];
    if writeoutput
        save -append -ascii "IndirectInferenceResults.out" temp;
    end   
end
