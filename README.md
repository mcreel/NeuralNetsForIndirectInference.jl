# NeuralNetsForIndirectInference.jl

-----------------------------------------------------------------------------------------------------------------------------
For work which builds on this, please see my archives SNM and the registered Julia package SimulatedNeuralMoments. The SV example is now included in the SimulatedNeuralMoments package.

Basically, the code archived here should not be run, it is just kept to document exactly what was done to create the results reported in the paper.

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
