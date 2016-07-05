using JLD

function sample_from_prior()
    # this just does rejection sampling to
    # stay in the identified region of the 
    # MA(2) model. I'm too lazy to reflect 
    # the bad draws
    ok = false
    theta1 = 0.
    theta2 = 0.
    while !ok
        theta1 = 4. * rand() - 2.
        theta2 = 2. * rand() - 1.
        ok = (theta2 > -1. + theta1) & (theta2 > -1. - theta1)
    end
    return [theta1 theta2]

end

function ma2(theta, n)
    e = randn(n+2)
    y = e[3:end] + theta[1]*e[2:end-1] + theta[2]*e[1:end-2]
end

function lags(x,p)
    cols = size(x,2)
    result = zeros(size(x,1), cols*p)
    for i = 1:p
        result[:,i*cols-cols+1:i*cols] = [ones(i,cols); x[1:end-i,:]]
    end
    return result
end

# fits an AR(P) model to MA(2) data
function aux_stat(theta, n, P)
    y = ma2(theta,n)
    x = lags(y,P)
    y = y[P+1:end]
    x = [ones(n-P,1) x[P+1:end,:]]
    Z = x\y
    return Z
end    

n = 100 # sample size
R = 1000000 # replications
P = 10 # order of AR fit to the data
thetas = zeros(R,2)
Zs = zeros(R,P+1)
for i = 1:R
    if mod(i,10000)== 0. 
        println(i)
    end    
    theta = sample_from_prior()
    thetas[i,:] = theta'
    Zs[i,:] = aux_stat(theta, n, P)
end

save("MA2data.jld","thetas", thetas, "Zs", Zs)


