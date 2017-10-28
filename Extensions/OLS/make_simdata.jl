# generate draws from linear regression model, and
# fitted coefficients from correct model, plus
# quadratic and cubic models (irrelevant regressors)
# and 5 pure noise statistics
#
# the trueparams argument allows for bootstrapping
function make_simdata(reps=100000, trueparams=ones(6,1), scale=true)
    n = 30
    simdata = zeros(reps, 35+6)
    Threads.@threads for rep = 1:reps
        # draw the regressors
        x = randn(n,4)
        z = [ones(n,1) x]
        # draw the parameters from prior (or use provided)
        if trueparams == ones(6,1)
            b = randn(5,1)
            sig = 0.1 + exp(randn(1,1))
        else
            b = trueparams[1:5,1]
            sig = trueparams[6,1]
        end    
        # generate dependent variable
        y = z*b + sig.*randn(n,1)
        # linear model
        bhat1 = z\y
        uhat = y-z*bhat1
        sighat1 = sqrt.(uhat'*uhat/(n-size(z,2)))
        # quadratic model
        z = [ones(n,1) x 0.1*x.^2.0]
        bhat2 = z\y
        uhat = y-z*bhat2
        sighat2 = sqrt.(uhat'*uhat/(n-size(z,2)))
        # cubic model
        z = [ones(n,1) x 0.1*x.^2.0 0.01*x.^3.0]
        bhat3 = z\y
        uhat = y-z*bhat3
        sighat3 = sqrt.(uhat'*uhat/(n-size(z,2)))
        # pure noise
        z = randn(1,5)
        # assemble: 
        simdata[rep,:] = [b' sig bhat1' log.(sighat1) bhat2' log.(sighat2) bhat3' log.(sighat3) z]
        #simdata[rep,:] = [b' sig bhat1' sighat1 bhat2' sighat2 bhat3' sighat3 z]
    end
    if scale
        X = simdata[:,7:end]
        X, mX, sX = stnorm(X)
        writedlm("mX", mX)
        writedlm("sX", sX)
        simdata[:,7:end] = X
    end
    return simdata
end

