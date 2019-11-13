using Statistics, Random

function prior(theta, lb, ub)
    a = 0.0
    if(all((theta .>= lb) .& (theta .<= ub)))
        a = 1.0
    end
    return a
end

# uniform random walk, with bounds check
function proposal1(current, tuning, lb, ub)
    trial = copy(current)
    if rand() > 0.1
        i = rand(1:size(current,1))
        trial[i] = current[i] + tuning[i].*randn()
    else
        trial = lb + (ub - lb).*rand(size(lb))
    end    
    return trial
end

function proposal2(current, cholV, lb, ub)
    trial = copy(current)
    if rand() > 0.1
        trial += cholV'*randn(size(trial))
    else
        trial = lb + (ub - lb).*rand(size(lb))
    end


end


# version which generates shock internally
function SVmodel(θ, n, burnin)
    η = randn(n+burnin)
    ϵ = randn(n+burnin)
    SVmodel(θ, n, η, ϵ, false)
end    

# the dgp: simple discrete time stochastic volatility (SV) model
function SVmodel(θ, n, η, ϵ, savedata=false)
    ϕ = θ[1]
    ρ = θ[2]
    σ = θ[3]
    burnin = size(η,1) - n
    hlag = 0.0
    ys = zeros(n,1)
    for t = 1:burnin+n
        h = ρ*hlag + σ*η[t] # figure out type
        σt = ϕ*exp(h/2.0)
        y = σt*ϵ[t]
        if t > burnin 
            ys[t-burnin] = y
        end    
        hlag = h
    end
    if savedata == true
        writedlm("svdata.txt", ys)
    end    
    σt = ϕ*exp(hlag/2.0)
    ys, σt # return the sample of returns, plus the final period volatility
end
using Statistics

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
    clusters = quantile(mm,0.75)-quantile(mm, 0.25)
    mm = ma(y,10)
    mm = mm[10:end]
    clusters2 = quantile(mm,0.75)-quantile(mm, 0.25)
    # HAR model, for all params
    vcat(α, m, s, k, clusters, clusters2, HAR(y))
end

