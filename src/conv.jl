
using StaticArrays
using DSP
function conv(u::AbstractArray{S}, v::AbstractArray{T}, p) where {S<:AbstractVector,T<:AbstractVector}
    n = length(u[1])
    if p == :dot
        sum(conv.([getindex.(u, i) for i = 1:n], [getindex.(v, i) for i = 1:n]))
    elseif p == :exterior
        map([conv(getindex.(u, i), v) for i = 1:n]...) do a...
            SVector{n}.(eachrow(hcat(a...)))
        end
    end

end
function conv(u::AbstractArray{S}, v::AbstractArray{T},) where {S<:Number,T<:AbstractVector}
    n = length(v[1])
    r = [conv(u, getindex.(v, i)) for i = 1:n]
    map(r...) do v...
        # SVector{n}(collect(v))
        SVector(v...)
    end
end
function conv(u::AbstractArray{S}, v::AbstractArray{T},) where {S<:AbstractVector,T<:Number}
    conv(v, u)
end
function conv(u::AbstractArray{S}, v::AbstractArray{T},) where {S<:Number,T<:Number}
    DSP.conv(u, v)
end