# L1 norm defined for use in penalty
norm1(x)= norm(x,1)
# L1 regularization penalty
L1penalty(θ) = sum(norm1,θ)
# L2 regularization penalty
L2penalty(θ) = sum(norm,θ)

struct DataIterator
   X
   Y
end

Base.length(xy::DataIterator) = min(size(xy.X, 2), size(xy.Y,2))

function Base.iterate(xy::DataIterator, idx=1)
   # Return `nothing` to end iteration
   if idx > length(xy)
       return nothing
   end
   # Pull out the observation and ground truth at this index
   result = (xy.X[:,idx], xy.Y[:,idx])
   # step forward
   idx += 1
   # return result and state
   return (result, idx)
end

function BoundByQuantiles!(data, margin=0.005)
for j = 1:size(data,2)
    q = quantile(data[:,j],margin)
    data[:,j] = max.(q,data[:,j])
    q = quantile(data[:,j],1.0-margin)
    data[:,j] = min.(q,data[:,j])
end
end

#=
# unsmoothed objective
function QRobj(yhat, y, τ)
    if τ == -1 τ = Array(range(0.1, step=0.1, stop = 0.9)) end
    d = size(y,1)
    obj = 0.0
    for i = 1:size(τ,1)
        ξ = y .- yhat[d*i-d+1:d*i]
        a = τ[i].*ξ.*(ξ .> 0.0) .+ (τ[i] .- 1.0).*ξ.*(ξ .< 0.0)
        obj += sum(a)
    end
    return obj
end
=#
# unsmoothed objective
function QRobj(yhat, y, x, τ)
    z = 10.0*(y .- yhat)
    ξ = τ .- 1.0./(1.0 .+ exp.(-z))
    a = abs.(x .* ξ)
    sum(a)
end

# smoothed objective
function SmoothQRobj(yhat, y, x, τ, α=0.02)
    if τ == -1 τ = Array(range(0.1, step=0.1, stop = 0.9)) end
    d = size(y,1)
    obj = 0.0
    for i = 1:size(τ,1)
        ξ = y .- yhat[d*i-d+1:d*i]
        a = x.*(τ[i].*ξ .+ α.*log.(1.0 .+ exp.(-1.0 .* ξ./α)))
        obj = obj .+ sum(a.*a)
    end
    return obj
end

