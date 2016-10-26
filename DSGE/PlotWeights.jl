# get the first layer parameters for influence analysis
open("visualize.dot", "w") do io
      println(io, mx.to_graphviz(lstm))
  end
  run(pipeline(`dot -Tsvg visualize.dot`, stdout="visualize.svg"))

beta = copy(model.arg_params[:fullyconnected0_weight])
z = maximum(abs(beta),2);
cax3 = matshow(z', interpolation="nearest")
colorbar(cax3)
xlabels = [string(i) for i=1:40]
xticks(0:39, xlabels)

