using Statistics, Econometrics
function Analyze(chain)
    posmean = vec(mean(chain,dims=1))
    posmedian = vec(median(chain,dims=1))
    inci = zeros(3)
    lower = zeros(3)
    upper = zeros(3)
    for i = 1:3
        lower[i] = quantile(chain[:,i],0.05)
        upper[i] = quantile(chain[:,i],0.95)
        inci[i] = θtrue[i] >= lower[i] && θtrue[i] <= upper[i]
    end
    return vcat(posmean[:], posmedian[:], lower[:], upper[:], inci[:])
end   

