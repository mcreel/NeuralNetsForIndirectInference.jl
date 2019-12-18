using Econometrics, StatsBase
using BSON: @load
using BSON: @save

function MakeData()
    data = 0.0
    datadesign = 0.0
    S = TrainingTestingSize
    # training and testing
    for s = 1:S
        θ = rand(size(lb,1)).*(ub-lb) + lb
        m = WileE_model(θ)
        if s == 1
            data = zeros(S, size(vcat(θ, m),1))
        end
        data[s,:] = vcat(θ, m)
    end
    # save needed items with standard format
    @save "raw_data.bson" data
    return nothing
end
