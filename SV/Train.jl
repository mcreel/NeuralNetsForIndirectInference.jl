using Pkg
Pkg.activate(".")
using Econometrics, Statistics, Flux, Random, LinearAlgebra
using Base.Iterators
using BSON: @load
using BSON: @save
include("SupportFunctions.jl")

function main()
    @load "data.bson" data datadesign
    data = Float32.(data)
    datadesign = Float32.(datadesign)
    whichdep = 1:3
    S = size(data,1)
    trainsize = Int(0.5*S)
    BatchProportion = 0.05 # proportion of train size used in batches
    yin = data[1:trainsize, whichdep]'
    yout = data[trainsize+1:end, whichdep]'
    x = data[:,4:end]
    xin = x[1:trainsize, :]'
    xout = x[trainsize+1:end, :]'
    ydesign = datadesign[:, whichdep]'
    xdesign = (datadesign[:, 4:end])'
    # model
    model = Chain(
<<<<<<< HEAD
        Dense(size(xin,1),15, relu),
        Dense(15,3)
=======
        Dense(size(xin,1),3*size(xin,1), tanh),
        Dense(3*size(xin,1),3*size(yout,1), tanh),
        Dense(3*size(yout,1),size(yout,1))
>>>>>>> f105696cdd75bc6a07fae5068a38a5792c3a10f3
    )
    θ = Flux.params(model)
    opt = AdaMax()
    loss(x,y) = Flux.mse(model(x),y) #+ 0.0001*L2penalty(θ)
    function monitor(e)
        println("epoch $(lpad(e, 4)): (training) loss = $(round(loss(xin,yin); digits=4)) (testing) loss = $(round(loss(xout,yout); digits=4))| ")
    end
    bestsofar = 1.0e10
    pred = 0.0 # define is here to have it outside the for loop
    inbatch = 0
<<<<<<< HEAD
    for i = 1:500
        batches = [(xin[:,ind],yin[:,ind])  for ind in partition(1:size(yin,2), 32)];
        Flux.train!(loss, θ, batches, opt)
        current = loss(xout,yout)
=======
    for i = 1:200
        inbatch = rand(size(xin,2)) .< BatchProportion
        batch = DataIterator(xin[:,inbatch],yin[:,inbatch])
        Flux.train!(loss, θ, batch, opt)
        current = loss(xout,yout).data
>>>>>>> f105696cdd75bc6a07fae5068a38a5792c3a10f3
        if current < bestsofar
            bestsofar = current
            @save "best.bson" model
            xx = xdesign
            yy = ydesign
            println("________________________________________________________________________________________________")
            monitor(i)
            pred = model(xx)
            error = yy .- pred
            results = [pred;error]
            rmse = sqrt.(mean(error.^2.0,dims=2))
            println(" ")
            println("True values α, ρ, σ: ")
            prettyprint(reshape(round.(yy[1:3,1],digits=3),1,3))
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
