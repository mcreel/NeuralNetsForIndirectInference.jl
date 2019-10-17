using Pkg
Pkg.activate(".")
using SV, Econometrics
using BSON: @save

function MakeData()
    n = 1000
    burnin = 100
    S = Int(5e2)
    # true parameters
    α = exp(-0.736/2.0)
    ρ = 0.9
    σ = 0.363
    θtrue = [α, ρ, σ] # true param values, on param space
    lb = [0.0, 0.0, 0.0]
    ub = [2.0, 0.99, 2.0]
    data = 0.0
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
    # for the aux. stats., use their quantiles instead of raw values
    for i = 4:size(data,2)
        tmp = sortperm(data[:,i])
        data[:,i] = tmp/S
    end
    @save "data.bson" data
    return nothing
end
MakeData()
