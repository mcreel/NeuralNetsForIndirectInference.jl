# NeuralNetsForIndirectInference.jl

-----------------------------------------------------------------------------------------------------------------------------
This code accompanies the paper "Neural Nets for Indirect Inference" https://www.sciencedirect.com/science/article/pii/S2452306216300326
This paper explore using neural nets to map a vector of statistic using data generated from a structural model to the parameter vector that characterizes the structural model. The code here will be difficult to actually run now, as the Julia packages it uses are no longer maintained. The registered and maintained Julia package https://github.com/mcreel/SimulatedNeuralMoments.jl implements the methods discussed in the paper, and contains the Stochastic Volatility example. 

The results of that original article are extended in the paper "Inference Using Simulated Neural Moments" https://www.mdpi.com/2225-1146/9/4/35, which shows that confidence intervals based on the simulated neural moments of the original paper have correct coverage, and also that the estimator has good RMSE and bias properties, compared to traditional simulated method of moments estimators.

The results are further extended in the paper "Constructing Efficient Simulated Moments Using Temporal Convolutional Networks" with J. Chassot (under review) https://jldc.ch/uploads/2023_chassot_creel.pdf This last paper does away with the need to specify statistics: the net is used to directly map the data from the model to the parameters that generated the data. This approach has the advantage of avoiding information loss due to a poor choice of statistics. The methods can rival the RMSE properties of the maximum likelihood estimator, for small and moderately sized samples.


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
