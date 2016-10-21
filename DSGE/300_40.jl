#=
This script trains and saves the 300-40 MLP for the DSGE example, computes
RMSE for the Monte Carlo data, and creates the plot
=#
using MXNet,PyPlot

# size of layers
layer1 = 300
layer2 = 40
outputs = 9
include("dataprep.jl") # creates X,Y,XT,YT, the training and testing inputs and output
# how to set up data providers using data in memory
batchsize = 2048 # can adjust this later, but must be defined now for next line
trainprovider = mx.ArrayDataProvider(:data => X, batch_size=batchsize, shuffle=false, :label => Y)
evalprovider = mx.ArrayDataProvider(:data => XT, batch_size=batchsize, shuffle=false, :label => YT)
# set up 2 layer MLP with 2 outputs
data = mx.Variable(:data)
label = mx.Variable(:label)
net  = @mx.chain    mx.FullyConnected(data = data, num_hidden=layer1) =>
                    mx.Activation(act_type=:tanh) =>
                    mx.FullyConnected(num_hidden=layer2) =>
                    mx.Activation(act_type=:tanh) =>
                    mx.FullyConnected(num_hidden=outputs)        
# squared error loss is appropriate for regression, don't change
cost = mx.LinearRegressionOutput(data = net, label=label)
# final model definition, don't change, except if using gpu
model = mx.FeedForward(cost, context=mx.cpu())
# set up the optimizer: select one, explore parameters, if desired
# optimizer = mx.SGD(lr=0.01, momentum=0.9, weight_decay=0.00001)
optimizer = mx.ADAM()
# train, reporting loss for training and evaluation sets
# initial training with small batch size, to get to a good neighborhood
batchsize = 256
mx.fit(model, optimizer, initializer=mx.NormalInitializer(0.0,0.01), eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 200)
# more training with larger sample, saving the final fitted model
batchsize = 2048
mx.fit(model, optimizer, eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 20, callbacks=[mx.do_checkpoint("dsge30040", frequency=20, save_epoch_0=false)])
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
relbias = 100*bias ./ mean(YMC',1) # relative measures, in percentage
relrmse = 100*rmse ./ mean(YMC',1)
@printf("    bias      rmse       mse   relbias   relrmse\n")
for i=1:size(bias,2)
    @printf("%8.5f  %8.5f  %8.5f  %8.5f  %8.5f\n", bias[i], rmse[i], mse[i], relbias[i], relrmse[i])
end
# get the first layer parameters for influence analysis
beta = copy(model.arg_params[:fullyconnected0_weight])
z = maximum(abs(beta),2);
cax3 = matshow(z', interpolation="nearest")
colorbar(cax3)
xlabels = [string(i) for i=1:40]
xticks(0:39, xlabels)

