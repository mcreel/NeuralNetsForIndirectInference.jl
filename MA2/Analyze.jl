using JLD
using PyPlot
plt = PyPlot

# load trained parameters, and separate them out
d = load("100_20_snapshots/snapshot-200000.jld")
params = d["params_all"]
h1 = params["hidden1"]
alpha1 = h1[2]
beta1 = h1[1]
h2 = params["hidden2"]
alpha2 = h2[2]
beta2 = h2[1]
output = params["output"]
alpha3 = output[2]
beta3 = output[1]

# load the Monte Carlo data (10000 replications)
include("dataprep.jl")
y = YT'   # YT, XT  are the testing outputs and inputs
x = XT'
trainsize = 900000
testsize = 100000
# get least squares fit using only the training data
thetas = thetas[trainsize+1:trainsize+testsize,:]
preprocess = preprocess[trainsize+1:trainsize+testsize,:]

# get the fit
h1 = tanh(alpha1' .+ x*beta1)
h2 = tanh(alpha2' .+ h1*beta2)
fit = alpha3' .+ h2*beta3

# compute RMSE, etc
error = thetas - [preprocess + sErrors.*fit]
bias = mean(error,1)
mse = mean(error.^2,1)
rmse = sqrt(mse)
#figure(1)
#cax1 = scatter(thetas[:,1],preprocess[:,1]+fit[:,1])
#xlabel("theta1")
#ylabel("fitted theta1")
#figure(2)
#cax2 = scatter(thetas[:,2],preprocess[:,2]+fit[:,2])
#xlabel("theta2")
#ylabel("fitted theta2")

@printf("    bias      rmse       mse\n")
for i=1:size(bias,2)
    @printf("%8.5f  %8.5f  %8.5f\n", bias[i], rmse[i], mse[i])
end

#bump = (alpha3' .+ tanh(alpha2' .+ tanh(alpha1' .+ 1. *beta1)*beta2)*beta3)
#base = (alpha3' .+ tanh(alpha2' .+ tanh(alpha1' .+ -1. * beta1)*beta2)*beta3)
#z = bump-base
#z = z ./ std(y,1)
#alpha = ["theta1", "theta2"]
z = maximum(abs(beta1),2);
cax3 = matshow(z', interpolation="nearest")
colorbar(cax3)
xlabels = [string(i) for i=1:11]
xticks(0:10, xlabels)
#yticks(0:1,alpha)

