using MXNet
# this script makes predictions
function GetNetFit(savefile, data, trainsize, noutputs)
    X = data[trainsize+1:end,noutputs+1:end]'
    model = mx.load_checkpoint(savefile, 20, mx.FeedForward) # load trained model
    # obtain predictions
    provider = mx.ArrayDataProvider(:data => X)
    fit = mx.predict(model, provider)'
end

