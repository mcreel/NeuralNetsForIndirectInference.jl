This directory has an example of indirect inference via neural net for a
simple discrete time stochastic volatility model. This runs on julia 1.x and
current Flux.jl, one of the actively maintained deep learning packages.

To use this, follow these steps. The first time, it will take 
a little time, because packages need to be downloaded and compiled.
The subsequent uses will be a lot faster.

1. git clone https://github.com/mcreel/NeuralNetsForIndirectInference.jl.git
2. cd to the SV subdirectory and start julia
3. enter package management by typing ]
    * type activate .  (notice the period there!)
    * type instantiate   (this installs all the needed packages, takes a bit)
    * type CTRL-C   (to go back to the Julia REPL)
4. create the training data and Monte Carlo data by
    include("MakeData.jl")   # this is inefficient as written, could be
    threaded
5. train the net and see results by
    include("Train.jl")
