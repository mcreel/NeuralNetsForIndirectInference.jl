using Statistics, Random

# version which generates shock internally
function SVmodel(θ, n, burnin)
    ϕ = θ[1]
    ρ = θ[2]
    σ = θ[3]
    hlag = 0.0
    ys = zeros(n)
    for t = 1:burnin+n
        # bound the log variance at a high value,
        # too bullet-proof things which use this
        h = min(ρ*hlag + σ*randn(),20.0)
        y = ϕ*exp(h/2.0)*randn()
        if t > burnin 
            ys[t-burnin] = y
        end    
        hlag = h
    end
    ys, ϕ*exp(hlag/2.0) # return the sample of returns, plus the final period volatility
end

# auxiliary model: HAR-RV
# Corsi, Fulvio. "A simple approximate long-memory model
# of realized volatility." Journal of Financial Econometrics 7,
# no. 2 (2009): 174-196.
function HAR(y)
    ylags = lags(y,10)
    X = [ones(size(y,1)) ylags[:,1]  mean(ylags[:,1:4],dims=2) mean(ylags[:,1:10],dims=2)]
    # drop missings
    y = y[11:end]
    X = X[11:end,:]
    βhat = X\y
    σhat = std(y-X*βhat)     
    vcat(βhat,σhat)
end

function aux_stat(y)
    α = sqrt(mean(y.^2.0))
    y = abs.(y)
    m = mean(y)
    s = std(y)
    k = std(y.^2.0)
    # look for evidence of volatility clusters, for ρ
    mm = ma(y,5)
    mm = mm[5:end]
    clusters1 = quantile(mm,0.75)-quantile(mm, 0.25)
    mm = ma(y,10)
    mm = mm[10:end]
    clusters2 = quantile(mm,0.75)-quantile(mm, 0.25)
    vcat(α, m, s, k, clusters1, clusters2, HAR(y), mean(cos.(y)), mean(sin.(y)), mean(cos.(2y)), mean(sin.(2y)))
end


# asymptotic Gaussian likelihood function of statistic
function logL(θ, m, n, η, ϵ, withdet=true)
    S = size(η,2)
    k = size(m,1)
    ms = zeros(S, k)
    Threads.@threads for s = 1:S
        y, junk = SVmodel(θ, n, η[:,s], ϵ[:,s])
        y = min.(y, 100.0)
        y = max.(y,-100.0)
        ms[s,:] = sqrt(n)*aux_stat(y)
    end
    mbar = mean(ms,dims=1)[:]
    if ~any(isnan.(mbar))
        Σ = cov(ms)
        x = (m .- mbar)
        lnL = try
            if withdet
                lnL = -0.5*log(det(Σ)) - 0.5*x'*inv(Σ)*x # for Bayesian
            else    
                lnL = 0.5*x'*inv(Σ)*x # for classic indirect inference (note sign change)
            end    
        catch
            lnL = -Inf
        end
     else
         lnL = -Inf
     end
     return lnL
end

# prior just checks that we're in the bounds
function prior(theta, lb, ub)
    a = 0.0
    if(all((theta .>= lb) .& (theta .<= ub)))
        a = 1.0
    end
    return a
end

# uniform random walk in one dimension
function proposal1(current, tuning, lb, ub)
    trial = copy(current)
    if rand() > 0.1
        i = rand(1:size(trial,1))
        trial[i] += tuning[i].*randn()
    else
        trial = lb + (ub - lb).*rand(size(lb,1))
    end    
    return trial
end

# MVN random walk, or occasional draw from prior
function proposal2(current, cholV, lb, ub)
    trial = copy(current)
    if rand() > 0.1
        trial += cholV'*randn(size(trial))
    else
        trial = lb + (ub - lb).*rand(size(lb,1))
    end
    return trial
end
