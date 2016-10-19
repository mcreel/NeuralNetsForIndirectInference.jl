using JLD
traintest = load("CTSV.jld", "simdata")
thetas = traintest[:,1:10]
Zs = traintest[:,11:end]
trainsize = 450000
mZs = mean(Zs,1)
sZs = std(Zs,1)
Zs = (Zs .- mZs) ./ sZs
# get least squares fit using only the training data
x = [ones(size(Zs,1)) Zs]
beta = x\thetas
# least squares errors, both train and test, using coefficients only from train
preprocess = x*beta
errors = thetas - preprocess
# standardize the inputs using stds of training data
sErrors = std(errors,1)
errors = errors ./ sErrors
Y = errors[1:trainsize,:]'
X = Zs[1:trainsize,:]'
YT = errors[trainsize+1:end,:]'
XT = Zs[trainsize+1:end,:]'
preprocess = preprocess[trainsize+1:end,:]
thetas = thetas[trainsize+1:end,:]
