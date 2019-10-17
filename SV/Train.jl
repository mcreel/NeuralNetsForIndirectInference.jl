using Pkg
Pkg.activate(".")
using Revise, Statistics, Flux, Flux.Tracker, Random, LinearAlgebra
using BSON: @load
using BSON: @save
include("NNlib.jl")

function main()
whichdep = 2:2
@load "data.bson" data
S = size(data,1)
trainsize = Int(0.5*S)
yin = data[1:trainsize, whichdep]'
yout = data[trainsize+1:end, whichdep]'
xin = data[1:trainsize, 4:end]'
xout = data[trainsize+1:end, 4:end]'

model = Chain(
  Dense(size(xin,1),5,tanh),
  Dense(5,5,tanh),
  Dense(5,1)
)
θ = Flux.params(model)
opt = AdaMax()
#loss(x,y) = Flux.mse(model(x),y) # + 0.1*L2penalty(θ) # QR with regularization
loss(x,y) = SmoothQRobj(model(x),y, x, 0.95) # + 0.1*L2penalty(θ) # QR with regularization
function monitor(e)
    println("epoch $(lpad(e, 4)): (training) loss = $(round(loss(xin,yin).data; digits=4)) (testing) loss = $(round(loss(xout,yout).data; digits=4))| ")
end
bestsofar = 1.0e10
inbatch = 0
a = 0.0
for i = 1:500
    inbatch = rand(size(xin,2)) .< 64.0/size(xin,2)
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
    end   
    if i % 1 == 0
        xx = xout
        yy = yout
        monitor(i)
        pred = (model(xx).data)
        results = yy .<= pred
        accuracy = mean(results,dims=2)
        println("% below quantile: ")
        prettyprint(reshape(round.(accuracy,digits=3),1,1))
    end
end
end 
main();
