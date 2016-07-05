using JLD
traintest = load("dsge.jld", "traintest")
thetas = traintest[:,1:9]
Zs = traintest[:,10:end]
trainsize = 500000
mZs = mean(Zs,1)
sZs = std(Zs,1)
Zs = (Zs .- mZs) ./ sZs
# get least squares fit using only the training data
x = [ones(size(Zs,1)) Zs]
beta = x\thetas
# least squares errors, both train and test, using coefficients only from train
errors = thetas - x*beta
# standardize the inputs using stds of training data
sErrors = std(errors,1)
errors = errors ./ sErrors
Y = errors[1:trainsize,:]'
X = Zs[1:trainsize,:]'
YT = errors[trainsize+1:end,:]'
XT = Zs[trainsize+1:end,:]'
x = 0
thetas = 0
traintest = 0
Zs = 0
