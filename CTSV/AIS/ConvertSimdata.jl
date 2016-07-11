using JLD
simdata = load("CTSV.jld", "simdata")
writedlm("simdata", simdata)

