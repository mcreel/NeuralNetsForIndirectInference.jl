function create_transformation(statistics)
    q005 = zeros(size(statistics,2))
    q995 = similar(q005)
    q50 = similar(q005)
    for i = 1:size(statistics,2)
        q005[i] = quantile(statistics[:,i],0.005)
        q50[i] = quantile(statistics[:,i],0.5)
        q995[i] = quantile(statistics[:,i],0.995)
    end
    info = [q005 q50 q995] 
    writedlm("transformation_info", info)
    return info
end

