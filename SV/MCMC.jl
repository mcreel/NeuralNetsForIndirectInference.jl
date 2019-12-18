# This does MCMC, either using raw statistic, or using NN transform,
# depending on the argument usenn
using Flux, Econometrics, LinearAlgebra, Statistics, DelimitedFiles
using BSON:@load
include("lib/transform.jl")
include("lib/lnL.jl")
function MCMC(m, usenn, info)
    # get the trained net
    @load "best.bson" model
    S = nSimulationDraws # number of simulations
    if usenn
        m = transform(m', info)
        m = Float64.(model(m'))
        θinit = (ub+lb)./2.0 # prior mean as initial θ
        lnL = θ -> LL(θ, m, S, model, info)
    else          
        θinit = (ub+lb)./2.0 # prior mean as initial θ
        lnL = θ -> LL(θ, m, S)
    end
    # use a rapid SAMIN to get good initialization values for chain
    obj = θ -> -1.0*lnL(θ)
    θinit, junk, junk, junk = samin(obj, θinit, lb, ub; coverage_ok=0, maxevals=100000, verbosity = 0, rt = 0.5)
    Prior = θ -> prior(θ, lb, ub) # uniform, doesn't matter
    # define things for MCMC
    verbosity = false
    ChainLength = 200
    tuning = [0.1, 0.1, 0.1] # fix this somehow
    Proposal = θ -> proposal1(θ, tuning, lb, ub)
    chain = mcmc(θinit, ChainLength, burnin, Prior, lnL, Proposal, verbosity)
    # now use a MVN random walk proposal with updates of covariance and longer chain
    # on final loop
    Σ = NeweyWest(chain[:,1:3])
    tuning = 1.0
    MC_loops = 4 # one round to adjust covariance, then the final
    for j = 1:MC_loops
        P = try
            P = (cholesky(Σ)).U
        catch
            P = diagm(diag(Σ))
        end    
        Proposal = θ -> proposal2(θ,tuning*P, lb, ub)
        if j == MC_loops
            ChainLength = 1000
        end    
        θinit = mean(chain[:,1:3],dims=1)[:]
        chain = mcmc(θinit, ChainLength, 0, Prior, lnL, Proposal, verbosity)
        if j < MC_loops
            accept = mean(chain[:,end])
            if accept > 0.35
                tuning *= 2.0
            elseif accept < 0.25
                tuning *= 0.25
            end
            Σ = 0.5*Σ + 0.5*NeweyWest(chain[:,1:3])
        end    
    end
    # plain MCMC fit
    chain = chain[:,1:3]
    return chain
end
