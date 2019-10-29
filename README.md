# NeuralNetsForIndirectInference.jl

NEW 29 Oct. 2019. The original examples archived here do no run on current Julia (1.x), and the packages that were used also do not
run on current Julia. The SV subdirectory contains an example for a simple discrete time stochastic volatility model, and this 
does run on current Julia, using the Flux.jl package, which is actively maintained, and is one of the main deep learning frameworks for 
Julia. See the readme in the SV directory for more information.

This repository provides the code to replicate the results in "Neural Nets for Indirect Inference", forthcoming in Econometrics and Statistics http://www.sciencedirect.com/science/article/pii/S2452306216300326 (a WP version is in the file NNII.pdf, in this repo), by Michael Creel.

The current code uses MXNet.jl, and runs with julia v0.5 or v0.4.

Release v1.0 uses the Mocha.jl package, and works with julia v0.4.

The code is a mixture of Julia and Octave. The julia code requires MXNet.jl and JLD.jl (and PyPlot.jl for plots). The Octave code requires support files available at https://github.com/mcreel/Econometrics.

Examples include a small dynamic stochastic general equilibirum (DSGE) model, a simple MA(2) model, and and example of estimation of a continuous time jump diffusion model using S&P500 data for Jan. 2015 - May 2016.

A stand alone example of estimation that uses the trained net is in the DSGE/EstimationExample directory. This allows you to estimate the parameters of a small (9 variables, 2 shocks) nonlinear DSGE model in less than 1 second. 

See the README files in the directories for instructions. Contact michael.creel@uab.cat for questions, etc.
