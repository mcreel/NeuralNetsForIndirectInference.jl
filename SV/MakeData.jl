using Pkg
Pkg.activate(".")
using SV, Econometrics, StatsBase
using BSON: @save
include("SupportFunctions.jl")

function MakeData()
    n = 500
    burnin = 100
    S = Int(1e5) # size of training and testing
    SS = 1000 # size of design 
    # true parameters
    α = exp(-0.736/2.0)
    ρ = 0.9
    σ = 0.363
    θtrue = [α, ρ, σ] # true param values, on param space
    lb = [0.0, 0.0, 0.0]
    ub = [2.0, 0.99, 1.0]
    data = 0.0
    datadesign = 0.0
    # training and testing
    for s = 1:S
        θ = rand(size(lb,1)).*(ub-lb) + lb
        y, volatility = SVmodel(θ, n, burnin)
        m = sqrt(n)*aux_stat(y)
        if s == 1
            data = zeros(S, size(vcat(θ, m),1))
        end
        data[s,:] = vcat(θ, m)
    end
    # design
    for s = 1:SS
        y, volatility = SVmodel(θtrue, n, burnin)
        m = sqrt(n)*aux_stat(y)
        if s == 1
            datadesign = zeros(SS, size(vcat(θtrue, m),1))
        end
        datadesign[s,:] = vcat(θtrue, m)
    end
    # normalize around median, and divide by abs val of median
    d = [data; datadesign]
    BoundByQuantiles!(d[:,4:end])
    for i = 4:size(d,2)
        q50 = quantile(d[:,i],0.5)
        d[:,i] = (d[:,i] .- q50) ./ abs(q50)
    end
    datadesign = d[S+1:end,:]
    data = d[1:S,:]
    @save "data.bson" data datadesign
    return nothing
end
MakeData()
