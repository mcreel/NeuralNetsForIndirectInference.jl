# this script makes predictions, gets RMSEs, and plots the figure
using MXNet, PyPlot
include("dataprep.jl") # load the data
model = mx.load_checkpoint("dsge30040", 20, mx.FeedForward) # load trained model
# obtain predictions
plotprovider = mx.ArrayDataProvider(:data => XMC, :label => YMC)
fit = mx.predict(model, plotprovider)
fit = fit'
fit = PostProcess(XMC', fit)
# compute RMSE
error = Y_orig - fit
bias = mean(error,1)
mse = mean(error.^2,1)
rmse = sqrt(mse)
relbias = 100*bias ./ Y_orig[[1],:] # relative measures, in percentage
relrmse = 100*rmse ./ Y_orig[[1],:]
@printf("    bias      rmse       mse   relbias   relrmse\n")
for i=1:size(bias,2)
    @printf("%8.5f  %8.5f  %8.5f  %8.5f  %8.5f\n", bias[i], rmse[i], mse[i], relbias[i], relrmse[i])
end
# get the first layer parameters for influence analysis
model = mx.load_checkpoint("dsge30040", 20) # load trained model
beta = copy(model[2][:fullyconnected0_weight])
z = maximum(abs(beta),2);
cax3 = matshow(z', interpolation="nearest")
colorbar(cax3)
xlabels = [string(i) for i=1:40]
xticks(0:39, xlabels)
println("")# stop PyPlot screen spam
#= This is how to make a schematic of the net
open("visualize.dot", "w") do io
      println(io, mx.to_graphviz(net))
end
run(pipeline(`dot -Tsvg visualize.dot`, stdout="visualize.svg"))
=#


