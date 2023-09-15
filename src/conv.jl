
using StaticArrays
using DSP
function DSP.conv(u::AbstractArray{S}, v::AbstractArray{T}) where {S<:AbstractVector,T<:AbstractVector}
    n = length(u[1])
    sum(DSP.conv.([getindex.(u, i) for i = 1:n], [getindex.(v, i) for i = 1:n]))
end
function DSP.conv(u::AbstractArray{S}, v::AbstractArray{T}) where {S<:Real,T<:AbstractVector}
    n = length(v[1])
    r = [DSP.conv(u, getindex.(v, i)) for i = 1:n]
    map(r...) do v...
        # SVector{n}(collect(v))
        SVector(v...)
    end
end