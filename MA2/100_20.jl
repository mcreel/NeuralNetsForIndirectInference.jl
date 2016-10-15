#=
The training script for the 100-20 node MLP for the MA2 model
=#
using MXNet
include("dataprep.jl") # creates X,Y,XT,YT, the training and testing inputs and output

# how to set up data providers using data in memory
batchsize = 256 # can adjust this later, but must be defined now for next line
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
optimizer = mx.SGD(lr=0.01, momentum=0.9, weight_decay=0.00001)
#optimizer = mx.ADAM()

# train, reporting loss for training and evaluation sets
# initial training with small batch size, to get to a good neighborhood
batchsize = 128
mx.fit(model, optimizer, initializer=mx.NormalInitializer(0.0,0.1), eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 500)
# more training with larger sample
batchsize = 2048
mx.fit(model, optimizer, eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 500)

#=
# obtain predictions
plotprovider = mx.ArrayDataProvider(:data => ValidationInput, :label => ValidationOutput)
fit = mx.predict(model, plotprovider)
plot(ValidationOutput,fit',".")
xlabel("true")
ylabel("predicted")
title("outputs: true versus predicted. 45º line is what we hope for")
=#    
