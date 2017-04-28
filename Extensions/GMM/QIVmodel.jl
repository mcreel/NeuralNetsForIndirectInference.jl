using Distributions

# the dgp. tau quantile of epsilon is 0,
# so tau quantile of y is x*beta
function makeQIVdata(beta::Array{Float64,1}, tau::Float64, n::Int64)
    alpha = [1.0,1.0,1.0]
    varscale = 5.0
    alpha = alpha / varscale
    Xi = randn(n,4)
    x = [ones(n,1) Xi[:,1] + Xi[:,2]]
    z = [ones(n,1) Xi[:,2] + Xi[:,3] Xi[:,1] + Xi[:,4]]
    m = -quantile(Normal(),tau)
    v = quantile(Normal(m),rand(n,1)) # tau quantile of v is 0
    epsilon = exp(((z*alpha) .^ 2.0).*v) - 1.0 #
    y = x*beta + epsilon
    cholsig = chol(tau*(1.0 -tau)*(z'*z/n))
    xhat = z*(z\x)
    yhat = z*(z\y)
    betahatIV = inv(x'*xhat)*x'*yhat
    return y,x,z,cholsig,betahatIV
end

# the moments
function aux_stat(beta::Array{Float64,1}, otherargs)
    y = otherargs[1]
    x = otherargs[2]
    z = otherargs[3]
    tau = otherargs[4]
    cholsig = otherargs[5]
    beta = reshape(beta,2,1)
    m = mean(z.*(tau .- (y .<= x*beta)),1)
    n = size(y,1);
    m = m + randn(size(m))*cholsig/sqrt(n)
    return m
end

# this function generates a draw from the prior
function sample_from_prior()
	theta = rand(2)
    lb = [0.0; 0.0]
    ub = [3.0; 3.0]
    theta = (ub-lb).*theta + lb
end

# the prior: needed to compute AIS density, which uses
# the prior as a mixture component, to maintain the support
function prior(theta::Array{Float64,1})
    lb = [0.0; 0.0]
    ub = [3.0; 3.0]
    c = 1./prod(ub - lb)
    p = ones(size(theta,1),1)*c
    ok = all((theta.>=lb) & (theta .<=ub),2)
    p = p.*ok
end    

function check_in_support(theta::Array{Float64,1})
    lb = [0.; 0.]
    ub = [3.; 3.]
    ok = all((theta .>= lb) & (theta .<= ub))
    return ok, lb, ub
end

