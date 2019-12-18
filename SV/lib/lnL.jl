# specialized likelihood for MCMC using net
function LL(θ, m, S, model, info)
    k = size(m,1)
    ms = zeros(S, k)
    Threads.@threads for s = 1:S
        ms[s,:] = Float64.(model(transform(WileE_model(θ[:])', info)'))
    end
    mbar = mean(ms,dims=1)[:]
    Σ = cov(ms)
    x = (m .- mbar)[:]
    lnL = try
        lnL =-0.5*log(det(Σ)) - 0.5*x'*inv(Σ)*x # for Bayesian
    catch
        lnL = -Inf
    end    
    return lnL
end

# version without net
function LL(θ, m, S)
    k = size(m,1)
    ms = zeros(S, k)
    Threads.@threads for s = 1:S
        ms[s,:] = WileE_model(θ[:])
    end
    mbar = mean(ms,dims=1)[:]
    Σ = cov(ms)
    x = (m .- mbar)[:]
    lnL = try
        lnL =-0.5*log(det(Σ)) - 0.5*x'*inv(Σ)*x # for Bayesian
    catch
        lnL = -Inf
    end    
    return lnL
end

