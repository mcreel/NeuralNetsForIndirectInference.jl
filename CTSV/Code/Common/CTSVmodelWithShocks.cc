// Euler function simulation, with RV and jump robust RV measures

// Continuous time SV model, version 4
// Notable features:
// * has drift that depends on spot vol (make constant by setting mu1 = 0)
// * dynamic jump intensity (make constant by setting lam1=0)
// * measurement error (turn off setting sig_eps = 0)
// * overnight period

// format [ret RV MedRV jumps hs] = CTSVmodel(theta, n, burnin, M, MM, MMM, shocks)
// theta: parameters
// n: number of days
// burnin: number of burnin days
// M: number of deltas per 24 hour day
// MM: number of deltas per trading day
// MMM: number of deltas between observations used to compute RV 
// outputs are daily values of returns, RV, jump robust RV, and number of jumps that days

#include <oct.h>
#include <oct-rand.h>
DEFUN_DLD(CTSVmodelWithShocks, args, ,"CTSVmodelWithShocks"){
    // parameters of model
    ColumnVector model_params (args(0).column_vector_value());
    const double mu0 = model_params(0); // constant part of drift in lnP
    const double mu1 = model_params(1); // volatility part of drift
    const double alpha = model_params(2);
    const double kappa = model_params(3);
    const double sig = model_params(4);
    const double rho = model_params(5);
    const double lam0 = model_params(6);  // base jump prob
    const double lam1 = model_params(7);  // coef on spot vol
    const double mu_j = model_params(8);  // mean jump size
    const double sig_j = model_params(9);  // std. dev. jump size
    const double sig_eps = model_params(10);  // std. error measurement error

       
    // controls for simulation
    int n (args(1).int_value());
    int burnin (args(2).int_value());
    int M (args(3).int_value()); // deltas per 24 hours
    int MM (args(4).int_value()); // deltas per trading period
    int MMM (args(5).int_value()); // deltas per observation
    const Matrix shocks (args(6).matrix_value()); // deltas per observation

    // other stuff
    const double delta = 1.0/((double) M);
    const double sqrtdelta = sqrt(delta);
    double h, hsdunits, lnY, lnY_observed, lnYlag_observed, lnYlag2, e1, e2, e3, e4, e5, ret, RV5, RV10, t3, t2, t1;
    double m, BV, MedRV, jump, njump, tjump, lambda, meas_error, sigt;
    int i, j, time_of_day;
    const double pi = 3.1415926;
    double  even;

    ColumnVector hs(n);
    ColumnVector rets(n);
    ColumnVector RV5s(n);
    ColumnVector RV10s(n);
    ColumnVector BVs(n);
    ColumnVector MedRVs(n);
    ColumnVector njumps(n);
    ColumnVector tjumps(n);
    ColumnVector lambdas(n);
    octave_value_list f_return;

    hs.fill(0.0);
    rets.fill(0.0);
    RV5s.fill(0.0);
    RV10s.fill(0.0);
    BVs.fill(0.0);
    MedRVs.fill(0.0);
    njumps.fill(0.0);
    tjumps.fill(0.0);
    lambdas.fill(0.0);

    // initialize
    h = alpha;
    lambda = lam0;
    lnY = 0.0;
    lnY_observed = 0.0;
    lnYlag_observed = 0.0;
    lnYlag2 = 0.0;
    j=0;
    njump = 0;
    tjump = 0;
    jump = 0.0;
    t1 = 0.0;
    t2 = 0.0;
    t3 = 0.0;
    RV5 = 0.0;
    RV10 = 0.0;
    BV = 0.0;
    MedRV = 0.0;
    time_of_day = 0;
    
    // main loop
    for (i=0; i < (n + burnin)*M; i++) {
        // this block runs constantly, night and day
        // shocks
        e1 = shocks(i,0);
        e2 = shocks(i,1);
        e3 = shocks(i,2);
        e4 = shocks(i,3);
        e5 = shocks(i,4);
        sigt = exp(h/2.0); // current spot st. dev.
        hsdunits = (h - alpha)/sig;
        
        // Poisson rate
        lambda = lam0 + lam0*lam1*hsdunits; // lam1 is factor that scales lam0, when h moves above or below mean, in sd units
        lambda = lambda * ((double) (lambda > 0.0)); // must be non-negative
        // is there a jump in log price?
        jump = 0.0;
        if (e4 < lambda*delta) { // jump occurs
            //  jump size: mu_j is mean, measured in spot sd units
            jump = mu_j + sig_j*e3;
            njump += 1; // number of occurences for day
            tjump += jump; // total impact of jumps for day
        }
                
        // returns
        //lnY = lnY + (mu0 + mu1*hsdunits - lambda*mu_j)*delta + sigt*sqrtdelta*e1 + jump;
        lnY = lnY + (mu0 + mu1*hsdunits)*delta + sigt*sqrtdelta*e1 + jump;
        
        // log volatility
        h = h + kappa*(alpha - h)*delta + sig*sqrtdelta*(rho*e1 + sqrt(1.0-rho*rho)*e2);
        
        // this block records the trading day info: high freq measures, and end of day price
        // the high frequency are seen every MMM movements of Euler approx
        if ((time_of_day < MM) && (i % MMM ==0.0))  {
            meas_error = sig_eps*e5; // meas error in log price 
            // explore effect of ME
            //double junk = meas_error / (sigt*sqrtdelta*e1);                        
            //printf("contrib of ME relative to ordinary vol: %f\n", junk);

            lnY_observed = lnY + meas_error; // meas. error affects observed, but not real
            ret = lnY_observed-lnYlag_observed; // put returns (and realized measures) in terms of percentages
            lnYlag_observed = lnY_observed;
            RV5 += ret*ret;
            // RV10 gets bumped half as often
            if (i % (2*MMM) == 0.0) RV10 += ret*ret;
            t3 = t2;
            t2 = t1;
            t1 = fabs(ret);
            // find median
            // t1 smallest
            if ((t1 < t2) && (t1 < t3) && (t2 < t3)) m = t2;
            if ((t1 < t2) && (t1 < t3) && (t3 < t2)) m = t3;
            // t2 smallest
            if ((t2 < t1) && (t2 < t3) && (t1 < t3)) m = t1;
            if ((t2 < t1) && (t2 < t3) && (t3 < t1)) m = t3;
            // t3 smallest
            if ((t3 < t1) && (t3 < t2) && (t1 < t2)) m = t1;
            if ((t3 < t1) && (t3 < t2) && (t2 < t1)) m = t2;
            // add up
            if (time_of_day > 0) BV += t1*t2; // don't take first one
            if (time_of_day > 1) MedRV += m*m; // don't take first two
        
            // record the values every day (a day is MM intervals of trading, then M-MM of overnight)
            if (time_of_day == MM-MMM) {  // this is true once a day, signals end of trading
                if (i>=burnin*M) {  // if burnin is over, record
                    lambdas(j) = lambda;
                    hs(j) = h;
                    rets(j) = lnY_observed - lnYlag2;
                    RV5s(j) = RV5;
                    RV10s(j) = RV10;
                    BVs(j) = BV;
                    MedRVs(j) = MedRV;
                    njumps(j) = njump;
                    tjumps(j) = tjump;
                    j += 1;  // index of days in sample (0 to n-1)
                }     
                lnYlag2 = lnY_observed; // record closing price for computing next day's return
                // back to zero for next day
                RV5 = 0.0;
                RV10 = 0.0;
                BV = 0.0;
                MedRV = 0.0;
                t1 = 0.0;
                t2 = 0.0;
                t3 = 0.0;
                njump = 0.0;
                tjump = 0.0;
                jump = 0.0;
            }
        }
        time_of_day += 1;
        if (time_of_day == M) time_of_day=0; // start a new day
    }        
    // adjust MedRV with constant part, to follow Dobrev + Szerszen eqn 4.
    MedRVs = pi/(6.0-4.0*sqrt(3.0) + pi)*MedRVs;
    BVs = pi/2.0*BVs;
    f_return(8) = lambdas;
    f_return(7) = hs;
    f_return(6) = tjumps;
    f_return(5) = njumps;
    f_return(4) = MedRVs;
    f_return(3) = BVs;
    f_return(2) = RV10s;
    f_return(1) = RV5s;
    f_return(0) = rets;

    return f_return;
}
