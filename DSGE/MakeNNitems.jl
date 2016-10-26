# this writes to disk the items that Octave needs to do II or BII estimation
include("dataprep.jl")
mZs, sZs, beta, sErrors = CreatePreprocessItems()
writedlm("beta", beta)
writedlm("mZs", mZs)
writedlm("sZs", sZs)
writedlm("sErrors", sErrors)
using MXNet
items = mx.load_checkpoint("dsge30040", 20)
alpha1 = copy(items[2][:fullyconnected0_bias])
alpha2 = copy(items[2][:fullyconnected1_bias])
alpha3 = copy(items[2][:fullyconnected2_bias])
beta1 = copy(items[2][:fullyconnected0_weight])
beta2 = copy(items[2][:fullyconnected1_weight])
beta3 = copy(items[2][:fullyconnected2_weight])
writedlm("alpha1", alpha1)
writedlm("alpha2", alpha2)
writedlm("alpha3", alpha3)
writedlm("beta1", beta1)
writedlm("beta2", beta2)
writedlm("beta3", beta3)
