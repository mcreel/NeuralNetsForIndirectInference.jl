include("MakeData.jl")
include("Transform.jl")
include("Train.jl")
include("Analyze.jl")

function RunProject()

# generate the raw training data
MakeData()

# transform the raw statistics, and split out params and stats
info = Transform()
# when this is done, can delete raw_data.bson

# train the net using the transformed training/testing data
Train()
include("Importance.jl")

end
RunProject()
