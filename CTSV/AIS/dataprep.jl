using JLD
simdata = load("CTSVnojumps.jld", "simdata")
writedlm("simdata", simdata)

