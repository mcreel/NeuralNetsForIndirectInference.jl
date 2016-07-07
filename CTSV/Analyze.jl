using JLD
#using PyPlot
#plt = PyPlot

# load trained parameters, and separate them out
d = load("TrainedNetAll.jld")
params = d["params_all"]
h1 = params["ip1"]
alpha1 = h1[2]
beta1 = h1[1]
h2 = params["ip2"]
alpha2 = h2[2]
beta2 = h2[1]
output = params["aggregator"]
alpha3 = output[2]
beta3 = output[1]

# run dataprep to define the scaling and preprocessing in the same
# way done before training
include("dataprep.jl")
# load montecarlo data
montecarlo = load("CTSV.jld", "simdata")
mcthetas = montecarlo[:,1:10]
mcZs = montecarlo[:,11:end]
# process the montecarlo data
mcZs = (mcZs .- mZs) ./ sZs
preprocess = [ones(size(mcZs,1),1) mcZs]  * beta
# get Monte Carlo fit
x = mcZs
h1 = tanh(alpha1' .+ x*beta1)
h2 = tanh(alpha2' .+ h1*beta2)
fit = alpha3' .+ h2*beta3
# assemble final fit
fit = fit.*sErrors + preprocess
#fit = fit + preprocess

# compute RMSE, etc
error = mcthetas - fit
bias = mean(error,1) ./mcthetas
rmse = sqrt(mean(error.^2,1))
rmse = rmse ./ mcthetas
@printf("    bias      rmse\n")
for i=1:size(bias,2)
    @printf("%8.5f  %8.5f \n", bias[i], rmse[i])
end

# write out this stuff to create NNitems for Octave
writedlm("alpha1", alpha1)
writedlm("alpha2", alpha2)
writedlm("alpha3", alpha3)
writedlm("beta1", beta1)
writedlm("beta2", beta2)
writedlm("beta3", beta3)
writedlm("mZs", mZs)
writedlm("sZs", sZs)
writedlm("beta", beta)
writedlm("sErrors", sErrors)

# this is the beginning of a more careful exploration of impacts of stats
# on each output. Not mature, but code is useful.
#bump = (alpha3' .+ tanh(alpha2' .+ tanh(alpha1' .+ 1. *beta1)*beta2)*beta3)
#x = x .-mean(x,1)
#x = x./std(x,1)
#base = (alpha3' .+ tanh(alpha2' .+ tanh(alpha1' .+ -1. * beta1)*beta2)*beta3)
#y = y .-mean(y,1)
#y = y./std(y,1)
#z = bump-base
#z = z .- mean(z,1)
#z = z ./ std(y,1)
#alpha = ["alpha", "beta", "delta", "gamma","rho_z","sig_z","rho_eta","sig_eta","nss"]

# this is the importance measure used in the paper
#z = maximum(abs(beta1),2)
#cax = matshow(z', interpolation="nearest")
#colorbar(cax)
#xlabels = [string(i) for i=1:40]
#xticks(0:39, xlabels);
#yticks(0:8,alpha)

