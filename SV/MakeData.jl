using Pkg
Pkg.activate(".")
using SV, Econometrics, StatsBase
using BSON: @save
include("SupportFunctions.jl")

function MakeData()
    n = 1000
    burnin = 1000
    S = Int(1e6) # size of training and testing
    SS = 10000 # size of design 
    # true parameters
    α = exp(-0.736/2.0)
    ρ = 0.9
    σ = 0.363
    θtrue = [α, ρ, σ] # true param values, on param space
    lb = [0.0, 0.0, 0.0]
    ub = [2.0, 0.99, 2.0]
    data = 0.0
    datadesign = 0.0
    # training and testing
    for s = 1:S
        shocks_u = randn(n+burnin)
        shocks_e = randn(n+burnin)
        θ = rand(size(lb,1)).*(ub-lb) + lb
        y, h = SVmodel(θ, n, shocks_u, shocks_e, false)
        volatility = θ[1]*exp(h/2.0)
        m = sqrt(n)*aux_stat(y)
        mm = ma(abs.(y),4)[end-4:end] # use a moving average of abs returns to identify current vol.
        if s == 1
            data = zeros(S, size(vcat(θ, volatility, m, mm),1))
        end
        data[s,:] = vcat(θ, volatility, m, mm)
    end
    # design
    for s = 1:SS
        shocks_u = randn(n+burnin)
        shocks_e = randn(n+burnin)
        y, h = SVmodel(θtrue, n, shocks_u, shocks_e, false)
        volatility = θtrue[1]*exp(h/2.0)
        m = sqrt(n)*aux_stat(y)
        mm = ma(abs.(y),4)[end-4:end]
        if s == 1
            datadesign = zeros(SS, size(vcat(θtrue, volatility, m, mm),1))
        end
        datadesign[s,:] = vcat(θtrue, volatility, m, mm)
    end
    # trim the conditioning variables by extreme quantiles to limit outliers,
    d = [data; datadesign]
    BoundByQuantiles!(d[:,5:end],0.005)
    datadesign = d[S+1:end,:]
    data = d[1:S,:]
    @save "data.bson" data datadesign
    return nothing
end
MakeData()
