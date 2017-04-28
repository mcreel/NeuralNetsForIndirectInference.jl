using MXNet
# main training function
function TrainNet(data, trainsize, noutputs, layerconfig, batchsize, epochs, savefile)
    # prepare data
    Y = data[1:trainsize,1:noutputs]'
    YT = data[trainsize+1:end,1:noutputs]'
    X = data[1:trainsize,noutputs+1:end]'
    XT = data[trainsize+1:end,noutputs+1:end]'
    # sizes of layers
    L1size = layerconfig[1]
    L2size = layerconfig[2]
    L3size = layerconfig[3]
    L4size = layerconfig[4]
    Outputsize = size(Y,1)
    # set up 2 layer MLP with 2 outputs
    data = mx.Variable(:data)
    label = mx.Variable(:label)
    if L4size != 0
        net  = @mx.chain    mx.Variable(:data) =>
                            mx.FullyConnected(num_hidden=L1size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=L2size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=L3size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=L4size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=Outputsize) =>
                            mx.LinearRegressionOutput(label)
    elseif L3size != 0
        net  = @mx.chain    mx.Variable(:data) =>
                            mx.FullyConnected(num_hidden=L1size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=L2size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=L3size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=Outputsize) =>       
                            mx.LinearRegressionOutput(label)
    else
        net  = @mx.chain    mx.Variable(:data) =>
                            mx.FullyConnected(num_hidden=L1size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(num_hidden=L2size) =>
                            mx.Activation(act_type=:relu) =>
                            mx.FullyConnected(name=:fc2, num_hidden=Outputsize) =>        
                            mx.LinearRegressionOutput(label)
    end
    model = mx.FeedForward(net, context=mx.cpu())
    trainprovider = mx.ArrayDataProvider(:data => X, shuffle=true, batch_size=batchsize, :label => Y)
    evalprovider = mx.ArrayDataProvider(:data => XT, shuffle=true, batch_size=batchsize, :label => YT)
    optimizer = mx.ADAM()
    mx.fit(model, optimizer, eval_metric=mx.MSE(),initializer=mx.NormalInitializer(), trainprovider, eval_data=evalprovider, n_epoch = epochs)
    optimizer = mx.SGD(lr=0.005, momentum=0.9, weight_decay=0.0001)
    mx.fit(model, optimizer, eval_metric=mx.MSE(), trainprovider, eval_data=evalprovider, n_epoch = epochs, callbacks=[mx.do_checkpoint(savefile, frequency=epochs, save_epoch_0=false)])
end    


