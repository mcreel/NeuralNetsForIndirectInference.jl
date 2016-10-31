# This script trains and saves the 300-40 MLP for the DSGE example
using MXNet
# size of layers
layer1 = 300
layer2 = 40
outputs = 9
include("dataprep.jl") # load training and testing data
# set up data providers
batchsize = 2048 # can adjust this later, but must be defined now for next line
trainprovider = mx.ArrayDataProvider(:data => X, batch_size=batchsize, shuffle=false, :label => Y)
evalprovider = mx.ArrayDataProvider(:data => XT, batch_size=batchsize, shuffle=false, :label => YT)
# set up 2 layer MLP with 2 outputs
data = mx.Variable(:data)
label = mx.Variable(:label)
net  = @mx.chain    mx.FullyConnected(data = data, num_hidden=layer1) =>
                    mx.Activation(act_type=:relu) =>
                    mx.FullyConnected(num_hidden=layer2) =>
                    mx.Activation(act_type=:relu) =>
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
mx.fit(model, optimizer, initializer=mx.NormalInitializer(0.0,0.05), eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 100)
# more training with larger sample, saving the final fitted model
batchsize = 2048
mx.fit(model, optimizer, eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = 20, callbacks=[mx.do_checkpoint("dsge30040", frequency=20, save_epoch_0=false)])

