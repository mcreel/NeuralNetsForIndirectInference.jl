# NeuralNetsForIndirectInference.jl
Julia code to use with Mocha.jl for DSGE and MA(2) examples of indirect inference using neural nets

This repository provides the code to replicate the results in "Neural Nets for Indirect Inference" (the paper is in the file NNII.pdf, in this repo), by Michael Creel.
The code require Mocha.jl and JLD.jl.

There are 3 examples: CTSV, DSGE and MA2
DSGE: this is discussed in section 4.1 of the paper
MA2: this is discussed in section 4.2 of the paper
CTSV: this is discussed in section 4.3 of the paper


A stand alone example of estimation that uses the trained net is in the DSGE/EstimationExample directory. This allows you to estimate the parameters of a small (9 variables, 2 shocks) nonlinear DSGE model in less than 1 second.

See the README files in the directories for instructions. Contact michael.creel@uab.cat for questions, etc.
