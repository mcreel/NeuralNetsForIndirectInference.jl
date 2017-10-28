include("make_simdata.jl")
# fit a neural net to the linear model data, and show influence of statistics
function main()
    data = make_simdata(500000)
    noutputs = 6
    trainsize = 350000
    savefile = "olsnet"
    layerconfig = [200, 30, 18, 0]
    TrainNet(data, trainsize, noutputs, layerconfig, 512, 30, savefile)
    params = ["α", "β₁","β₂","β₃","β₄","σ"]
    title = "linear regression example"
    # results for NN
    fit = AnalyzeNet(savefile, data, trainsize, noutputs, title=title, params=params, doplot=true)
    writedlm("olsfit", round.([data[trainsize+1:end,1:noutputs] fit],4))
end
main()
