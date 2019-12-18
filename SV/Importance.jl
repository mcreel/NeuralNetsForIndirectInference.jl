using BSON: @load
using Flux
using Plots
# get the first layer parameters for influence analysis
@load "best.bson" model
beta = model.layers[1].W # get first layer betas
z = maximum(abs.(beta),dims=1);
heatmap(z, xlabel="statistic", title="Importance of inputs, bright=high, dark=low")
savefig("ImportanceOfStatistics.svg")


