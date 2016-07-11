# NeuralNetsForIndirectInference.jl

This repository provides the code to replicate the results in "Neural Nets for Indirect Inference" (the paper is in the file NNII.pdf, in this repo), by Michael Creel.

The code is a mixture of Julia and Octave. The julia code requires Mocha.jl and JLD.jl.

Examples include a small dynamic stochastic general equilibirum (DSGE) model, a simple MA(2) model, and and example of estimation of a continuous time jump diffusion model using S&P500 data for Jan. 2015 - May 2016.

A stand alone example of estimation that uses the trained net is in the DSGE/EstimationExample directory. This allows you to estimate the parameters of a small (9 variables, 2 shocks) nonlinear DSGE model in less than 1 second. 

See the README files in the directories for instructions. Contact michael.creel@uab.cat for questions, etc.
