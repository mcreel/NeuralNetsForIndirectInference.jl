using JLD
function CreatePreprocessItems()
    traintest = load("dsge.jld", "traintest")
    thetas = traintest[:,1:9]
    Zs = traintest[:,10:end]
    mZs = mean(Zs,1)
    sZs = std(Zs,1)
    Zs = (Zs .- mZs) ./ sZs
    # get least squares fit
    x = [ones(size(Zs,1)) Zs]
    beta = x\thetas
    # least squares errors
    errors = thetas - x*beta
    # for standardization
    sErrors = std(errors,1)
    return mZs, sZs, beta, sErrors
end

function Preprocess(data)
    mZs, sZs, beta, sErrors = CreatePreprocessItems()
    Y_orig = data[:,1:9]
    Zs = data[:,10:end]
    Zs = (Zs .- mZs) ./ sZs
    x = [ones(size(Zs,1)) Zs]
    # least squares errors
    errors = Y_orig - x*beta
    # for standardization
    sErrors = std(errors,1)
    errors = errors ./ sErrors
    Y = errors'
    X = Zs'
    return Y,X, Y_orig 
end    

# this function takes the net's inputs and outputs
# and generates the fit for the original unprocessed
# outputs
function PostProcess(inputs, outputs)
    mZs, sZs, beta, sErrors = CreatePreprocessItems()
    x = [ones(size(inputs,1)) inputs]
    fit = x*beta + sErrors.*outputs # back to original location and scale
    # keep the fits inside support
    fit[:,6] = fit[:,6].*(fit[:,6].> 0.0)
    fit[:,8] = fit[:,8].*(fit[:,8].> 0.0)
    return fit
end    
traintest = load("dsge.jld", "traintest")
Y,X = Preprocess(traintest)
trainsize = 500000
YT = Y[:,trainsize+1:end]
XT = X[:,trainsize+1:end]
Y = Y[:,1:trainsize]
X = X[:,1:trainsize]
montecarlo = load("dsge.jld", "montecarlo")
YMC, XMC, Y_orig = Preprocess(montecarlo)

