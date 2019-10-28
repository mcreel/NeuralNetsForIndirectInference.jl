using Pkg
Pkg.activate(".")
using Econometrics, Statistics, Flux, Random, LinearAlgebra
using BSON: @load
using BSON: @save
include("SupportFunctions.jl")

function main()
    whichdep = 1:3
    @load "data.bson" data datadesign
    S = size(data,1)
    trainsize = Int(0.5*S)
    yin = data[1:trainsize, whichdep]'
    yout = data[trainsize+1:end, whichdep]'

    x = data[:,4:end]
    xin = x[1:trainsize, :]'
    xout = x[trainsize+1:end, :]'
    ydesign = datadesign[:, whichdep]'
    xdesign = (datadesign[:, 4:end])'
    # model
    model = Chain(
        Dense(size(xin,1),100, tanh),
        Dense(100,9, tanh),
        Dense(9,3)
    )
    θ = Flux.params(model)
    opt = AdaMax()
    P = (1.0 ./ std(data[:,1:3],dims=1))' # weight the errors vars by inverse of in sample std devs
    loss(x,y) = sqrt.(Flux.mse(P.*model(x),P.*y)) #+ 0.01*L2penalty(θ)
    function monitor(e)
        println("epoch $(lpad(e, 4)): (training) loss = $(round(loss(xin,yin).data; digits=4)) (testing) loss = $(round(loss(xout,yout).data; digits=4))| ")
    end
    bestsofar = 1.0e10
    pred = 0.0 # define is here to have it outside the for loop
    inbatch = 0
    for i = 1:50000
        inbatch = rand(size(xin,2)) .< 500.0/size(xin,2)
        batch = DataIterator(xin[:,inbatch],yin[:,inbatch])
        Flux.train!(loss, θ, batch, opt)
        current = loss(xout,yout).data
        if current < bestsofar
            bestsofar = current
            if whichdep == 1:3
                @save "best13.bson" model
            elseif whichdep == 1:1    
                @save "best1.bson" model
            elseif whichdep == 2:2    
                @save "best2.bson" model
            elseif whichdep == 3:3    
                @save "best3.bson" model
            end
            xx = xdesign
            yy = ydesign
            println("________________________________________________________________________________________________")
            monitor(i)
            pred = model(xx).data
            error = yy .- pred
            results = [pred;error]
            rmse = sqrt.(mean(error.^2.0,dims=2))
            println(" ")
            println("True values α, ρ, σ: ")
            prettyprint(reshape(round.(yy[:,1],digits=3),1,3))
            println(" ")
            println("RMSE for α, ρ, σ: ")
            prettyprint(reshape(round.(rmse,digits=3),1,3))
            println(" ")
            println("dstats prediction:")
            dstats(pred');
            println(" ")
            println("dstats prediction error:")
            dstats(error');
        end
    end
    return pred
end 
pred = main();