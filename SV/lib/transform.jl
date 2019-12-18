# bounds by quantiles, and standardizes and normalizes around median
function transform(data, info)
    q005 = info[:,1]
    q50 = info[:,2]
    q995 = info[:,3]
    data = max.(data, q005')
    data = min.(data, q995')
    data = (data .- q50') ./ abs.(q50')
    return data
end

