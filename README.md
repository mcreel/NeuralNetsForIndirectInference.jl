# NeuralNetsForIndirectInference.jl

-----------------------------------------------------------------------------------------------------------------------------

NEW 29 Oct. 2019. An example which runs on Julia 1.x

The original examples do not run on current Julia (1.x), and the deep learning packages that were used also do not
run on current Julia. The SV subdirectory contains an example for a simple discrete time stochastic volatility model, and this 
does run on current Julia, using the Flux.jl package, which is actively maintained, and is one of the main deep learning frameworks for Julia.

The example simulates data from the simple discrete time logarithmic stochastic volatility model::


    y(t) = a*exp(h(t)/2)*e(t)
    h(t) = b*h(t-1) + c*u(t)
    where e(t) and u(t) are IIN(0,1) shocks.


* The parameters are a, b and c.
* The prior is a uniform distribution over (a,b,c) in (0.05,2)X(0.05,1)X(0,1).
* The net is trained using draws from the prior, and samples of size n=1000.
* Representative results for testing set are::

![results](https://raw.githubusercontent.com/mcreel/NeuralNetsForIndirectInference.jl/master/results.png)

A plot of the importances of the inputs to the net (as discussed in the paper) is 
![statistics](https://raw.githubusercontent.com/mcreel/NeuralNetsForIndirectInference.jl/master/SV/ImportanceOfStatistics.png)

From this, we see that the second to last statistic is not important, and two of the others have a low importance. Some statistics are important. To know more about the statistics, see the function aux_stats.jl, at https://github.com/mcreel/SV/blob/master/src/aux_stat.jl

To replicate this, git clone the archive, cd to the SV directory, start julia, and do `` include("Setup.jl"); include("RunMe.jl"). The first time, this will take a while, because a lot of supporting packages must be installed. See the ``Manifest.toml`` file in the SV directory for the list of what will be installed into the project environment (not your main Julia environment).


-----------------------------------------------------------------------------------------------------------------------------
The original readme is preserved below. None of this runs anymore.
-----------------------------------------------------------------------------------------------------------------------------

This repository provides the code to replicate the results in "Neural Nets for Indirect Inference", forthcoming in Econometrics and Statistics http://www.sciencedirect.com/science/article/pii/S2452306216300326 (a WP version is in the file NNII.pdf, in this repo), by Michael Creel.

The current code uses MXNet.jl, and runs with julia v0.5 or v0.4.

Release v1.0 uses the Mocha.jl package, and works with julia v0.4.

The code is a mixture of Julia and Octave. The julia code requires MXNet.jl and JLD.jl (and PyPlot.jl for plots). The Octave code requires support files available at https://github.com/mcreel/Econometrics.

Examples include a small dynamic stochastic general equilibirum (DSGE) model, a simple MA(2) model, and and example of estimation of a continuous time jump diffusion model using S&P500 data for Jan. 2015 - May 2016.

A stand alone example of estimation that uses the trained net is in the DSGE/EstimationExample directory. This allows you to estimate the parameters of a small (9 variables, 2 shocks) nonlinear DSGE model in less than 1 second. 

See the README files in the directories for instructions. Contact michael.creel@uab.cat for questions, etc.
