# set up environment
ENV["MOCHA_USE_CUDA"] = "true"
#ENV["MOCHA_USE_NATIVE_EXT"] = "true"
using Mocha,JLD
srand(12345678)
backend = DefaultBackend()
init(backend)
snapshot_dir = "300_40_snapshots"
batchsize = 512
maxiters = 200000
# Load and pre-process the data
include("dataprep.jl")
# specify sizes of layers
Layer1Size = 300
Layer2Size = 40
# create the network
data = MemoryDataLayer(batch_size=batchsize, data=Array[X,Y])
h1 = InnerProductLayer(name="ip1",neuron=Neurons.Tanh(), output_dim=Layer1Size, tops=[:pred1], bottoms=[:data])
h2 = InnerProductLayer(name="ip2",neuron=Neurons.Tanh(), output_dim=Layer2Size, tops=[:pred2], bottoms=[:pred1])
output = InnerProductLayer(name="aggregator", output_dim=6, tops=[:output], bottoms=[:pred2] )
loss_layer = SquareLossLayer(name="loss", bottoms=[:output, :label])
common_layers = [h1,h2,output]
net = Net("train", backend, [data, common_layers, loss_layer])
# create the validation network
datatest = MemoryDataLayer(batch_size=50000, data=Array[XT,YT])
accuracy = SquareLossLayer(name="acc", bottoms=[:output, :label])
net_test = Net("test", backend, [datatest, common_layers, accuracy])
test_performance = ValidationPerformance(net_test)
# Solve
lr_policy=LRPolicy.Inv(0.01, 0.001, 0.8)
method = SGD()
params = make_solver_parameters(method, regularization_type="L2", regu_coef=0.000, mom_policy=MomPolicy.Fixed(0.9), max_iter=maxiters, lr_policy=lr_policy, load_from=snapshot_dir)
solver = Solver(method, params)
add_coffee_break(solver, TrainingSummary(), every_n_iter=1000)
add_coffee_break(solver, test_performance, every_n_iter=1000)
add_coffee_break(solver, Snapshot(snapshot_dir), every_n_iter=1000)
solve(solver, net)
Mocha.dump_statistics(solver.coffee_lounge, get_layer_state(net, "loss"), true)
destroy(net)
destroy(net_test)
shutdown(backend)
