using MXNet
using Econometrics.stnorm
using Econometrics.dstats
include("QIVmodel_s.jl") # load auction model code
include("TrainNet.jl")

function main()
    # make data
    reps = 1000000
    # features of model
    #srand(1223) # allow generating same data, to check different net archtectures
    n = 200  # sample size
    beta = [1., 1.] # true parameters
    tau = 0.5
    y,x,z = makeQIVdata(beta, tau, n) # draw the data
    cholsig = chol(tau*(1.0 -tau)*(z'z/n))
    otherargs = (y,x,z,tau,cholsig)
    data = zeros(reps,5)
    @simd for i = 1:reps
        beta = sample_from_prior()
        m = aux_stat(beta, otherargs)
        data[i,:] = [beta' m]
    end
    data = [zeros(1,5); data]
    data, mX, sX = stnorm(data)
    X = data[[1],3:end]'
    data = data[2:end,:]
    # train net
    noutputs = 2
    trainsize = Int64(0.8*reps)
    layerconfig = [100, 12, 0, 0]
    epochs = 10
    TrainNet(data, trainsize, noutputs, layerconfig, 1024, epochs, "gmmnet")
    # get fit
    model = mx.load_checkpoint("gmmnet", epochs, mx.FeedForward) # load trained model
    provider = mx.ArrayDataProvider(:data => X)
    fit = mx.predict(model, provider)
    fit = fit.*sX[1:2] + mX[1:2]
end
main()

