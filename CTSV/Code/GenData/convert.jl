using JLD
data = readdlm("simdata")
save("CTSV.jld", "simdata", data)
