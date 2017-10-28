include("make_simdata.jl")
include("GetNetFit.jl")
using Econometrics.stnorm
function main()
    TrueAndFit = readdlm("olsfit")
    inci90 = zeros(6)
    inci95 = zeros(6)
    inci99 = zeros(6)
    mX = readdlm("mX")
    sX = readdlm("sX")
    for i = 1:size(TrueAndFit,1)
        fit = TrueAndFit[[i],7:end]
        tru = TrueAndFit[[i],1:6]
        bootstrapdata = make_simdata(999, fit', false)
        X = bootstrapdata[:,7:end]
        X, junk, junk = stnorm(X,mX,sX)
        bootstrapdata[:,7:end] = X
        bootstrapfit = GetNetFit("olsnet", bootstrapdata, 0, 6)
        bootstrapfit = bootstrapfit .- mean(bootstrapfit .- fit,1)
        s = std(bootstrapfit,1)
        inci90 += (mean(abs(fit .- tru)./s,1)' .< 1.64485)
        inci95 += (mean(abs(fit .- tru)./s,1)' .< 1.95996)
        inci99 += (mean(abs(fit .- tru)./s,1)' .< 2.57583)
        #=
        for j = 1:6
            a = quantile(bootstrapfit[:,j],0.05)
            b = quantile(bootstrapfit[:,j],0.95)
            inci2[j] += ((a <= tru[1,j]) & (tru[1,j] <= b))
        end
        =#
        if mod(i,100)==10
            println(inci90/i)
            println(inci95/i)
            println(inci99/i)
        end
    end    
end
main()
