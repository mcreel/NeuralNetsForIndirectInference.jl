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

