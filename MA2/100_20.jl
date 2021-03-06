#=
The training script for the 100-20 node MLP for the MA2 model
=#
using MXNet,PyPlot
include("dataprep.jl") # creates X,Y,XT,YT, the training and testing inputs and output

# how to set up data providers using data in memory
batchsize = 2048 # can adjust this later, but must be defined now for next line
trainprovider = mx.ArrayDataProvider(:data => X, batch_size=batchsize, shuffle=false, :label => Y)
evalprovider = mx.ArrayDataProvider(:data => XT, batch_size=batchsize, shuffle=false, :label => YT)

# set up 2 layer MLP with 2 outputs
data = mx.Variable(:data)
label = mx.Variable(:label)
net  = @mx.chain    mx.FullyConnected(data = data, num_hidden=100) =>
                    mx.Activation(act_type=:tanh) =>
                    mx.FullyConnected(num_hidden=20) =>
                    mx.Activation(act_type=:tanh) =>
                    mx.FullyConnected(num_hidden=2)        

# squared error loss is appropriate for regression, don't change
cost = mx.LinearRegressionOutput(data = net, label=label)

# final model definition, don't change, except if using gpu
model = mx.FeedForward(cost, context=mx.cpu())

# set up the optimizer: select one, explore parameters, if desired
#optimizer = mx.SGD(lr=0.01, momentum=0.9, weight_decay=0.00001)
optimizer = mx.ADAM()

# train, reporting loss for training and evaluation sets
# initial training with small batch size, to get to a good neighborhood
batchsize = 128
mx.fit(model, optimizer, initializer=mx.NormalInitializer(0.0,0.1), eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 100)
# more training with larger sample
batchsize = 2048
mx.fit(model, optimizer, eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 10)

# obtain predictions
plotprovider = mx.ArrayDataProvider(:data => XT, :label => YT)
fit = mx.predict(model, plotprovider)
fit = fit'

# compute RMSE using the testing data
trainsize = 900000
testsize = 100000
thetas = thetas[trainsize+1:trainsize+testsize,:]
preprocess = preprocess[trainsize+1:trainsize+testsize,:]
fit = preprocess + sErrors.*fit
error = thetas - fit
# compute RMSE
bias = mean(error,1)
mse = mean(error.^2,1)
rmse = sqrt(mse)
@printf("    bias      rmse       mse\n")
for i=1:size(bias,2)
    @printf("%8.5f  %8.5f  %8.5f\n", bias[i], rmse[i], mse[i])
end

# get the first layer parameters for influence analysis
beta = copy(model.arg_params[:fullyconnected0_weight])
z = maximum(abs(beta),2);
cax3 = matshow(z', interpolation="nearest")
colorbar(cax3)
xlabels = [string(i) for i=1:11]
xticks(0:10, xlabels)

figure()
cax1 = scatter(thetas[:,1],fit[:,1])
xlabel("theta1")
ylabel("fitted theta1")

figure()
cax2 = scatter(thetas[:,2], fit[:,2])
xlabel("theta2")
ylabel("fitted theta2")

