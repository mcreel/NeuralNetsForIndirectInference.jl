using Pkg
Pkg.activate(".")
using SV, Econometrics, StatsBase
using BSON: @save

function MakeData()
    n = 1000
    burnin = 1000
    S = Int(5e5) # size of training and testing
    SS = 1000 # size of design 
    # true parameters
    α = exp(-0.736/2.0)
    ρ = 0.9
    σ = 0.363
    θtrue = [α, ρ, σ] # true param values, on param space
    lb = [0.0, 0.0, 0.0]
    ub = [1.0, 0.99, 1.0]
    data = 0.0
    datadesign = 0.0
    # training and testing
    for s = 1:S
        shocks_u = randn(n+burnin)
        shocks_e = randn(n+burnin)
        θ = rand(size(lb,1)).*(ub-lb) + lb
        y = SVmodel(θ, n, shocks_u, shocks_e, false)
        m = sqrt(n)*aux_stat(y)
        if s == 1
            data = zeros(S, size(vcat(θ, m),1))
        end
        data[s,:] = vcat(θ, m)
    end
    # design
    for s = 1:SS
        shocks_u = randn(n+burnin)
        shocks_e = randn(n+burnin)
        y = SVmodel(θtrue, n, shocks_u, shocks_e, false)
        m = sqrt(n)*aux_stat(y)
        if s == 1
            datadesign = zeros(SS, size(vcat(θtrue, m),1))
        end
        datadesign[s,:] = vcat(θtrue, m)
    end
    # stack them to get quantiles
    data = [data; datadesign]
    # for the aux. stats., use their quantiles instead of raw values
    for i = 4:size(data,2)
        tmp = data[:,i]
        data[:,i] = denserank(tmp)/(S+SS)
    end
    # unstack
    datadesign = data[(S+1):end,:]
    data = data[1:S,:]
    @save "data.bson" data datadesign
    return nothing
end
MakeData()
