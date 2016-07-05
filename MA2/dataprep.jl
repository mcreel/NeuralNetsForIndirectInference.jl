using JLD
thetas = load("MA2data.jld", "thetas")
Zs = load("MA2data.jld", "Zs")
# train is 900000, test is 100000
trainsize = 900000
testsize = 100000
# preprocess by OLS
x = [ones(size(Zs,1),1) Zs]
betas = x \ thetas
preprocess = x*betas
x = 0
errors = thetas - preprocess
# standardize the inputs using stds of training data
mZs = mean(Zs,1)
sZs = std(Zs,1)
Zs = (Zs .- mZs) ./ sZs
sErrors = std(errors,1)
errors = errors ./sErrors
Y = errors[1:trainsize,:]'
X = Zs[1:trainsize,:]'
YT = errors[trainsize+1:trainsize+testsize,:]'
XT = Zs[trainsize+1:trainsize+testsize,:]'
Zs = 0
errors = 0
 
