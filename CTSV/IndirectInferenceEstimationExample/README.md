# DSGE_Neural_Net_Estimation_Example


II_Estimate.m
This does indirect inference estimation of the model, using the statistic which is the output of the neural network to define the moment conditions.


The posterior mean function has previously been fit using a neural net, using the code at https://github.com/mcreel/NeuralNetsForIndirectInference.jl  Implementing this fit only requires prior information, so this part can be done before the actual sample is observed.

The model is solved using Dynare, with a 3rd order solution. The model is the same one described in  "Bayesian Indirect Inference and the ABC of GMM" by Creel, Gao, Hong and Kristensen, http://arxiv.org/abs/1512.07385 The Dynare .mod file is provided, see it for the details.

The present code requires Octave or Matlab, plus Dynare. I believe that it is completely self-contained, apart from these dependencies. The code has been checked using Octave. If there are problems running it with Matlab, please let me know.
