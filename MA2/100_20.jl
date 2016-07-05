# set up environment
ENV["MOCHA_USE_CUDA"] = "true"
#ENV["MOCHA_USE_NATIVE_EXT"] = "true"
using Mocha
srand(12345678)
backend = DefaultBackend()
init(backend)
snapshot_dir = "100_20_snapshots"
# Load the data and pre-process it
include("dataprep.jl")
# Define network
Layer1Size = 100
Layer2Size = 20
batchsize = 256
maxiters = 200000
# create the network
data = MemoryDataLayer(batch_size=batchsize, data=Array[X,Y])
h1 = InnerProductLayer(name="hidden1",neuron=Neurons.Tanh(), output_dim=Layer1Size, tops=[:pred1], bottoms=[:data])
h2 = InnerProductLayer(name="hidden2",neuron=Neurons.Tanh(), output_dim=Layer2Size, tops=[:pred2], bottoms=[:pred1])
output = InnerProductLayer(name="output", output_dim=2, tops=[:output], bottoms=[:pred2] )
loss_layer = SquareLossLayer(name="loss", bottoms=[:output, :label])
common_layers = [h1,h2,output]
net = Net("ma2-train", backend, [data, common_layers, loss_layer])
# create the validation network
datatest = MemoryDataLayer(batch_size=100000, data=Array[XT,YT])
accuracy = SquareLossLayer(name="acc", bottoms=[:output, :label])
net_test = Net("ma2-test", backend, [datatest, common_layers, accuracy])
test_performance = ValidationPerformance(net_test)
############################################################
# Solve
############################################################
lr_policy=LRPolicy.Inv(0.01, 0.001, 0.8)
method = SGD()
params = make_solver_parameters(method, regularization_type="L1", regu_coef=0.00001, mom_policy=MomPolicy.Fixed(0.9), max_iter=maxiters, lr_policy=lr_policy, load_from=snapshot_dir)
solver = Solver(method, params)
add_coffee_break(solver, TrainingSummary(), every_n_iter=10000)
add_coffee_break(solver, Snapshot(snapshot_dir), every_n_iter=10000)
add_coffee_break(solver, test_performance, every_n_iter=10000)
# link the decay-on-validation policy with the actual performance validator
solve(solver, net)
Mocha.dump_statistics(solver.coffee_lounge, get_layer_state(net, "loss"), true)
destroy(net)
destroy(net_test)
shutdown(backend)
