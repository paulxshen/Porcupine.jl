
using StaticArrays, LinearAlgebra
using DSP, FFTW

function fft(a::AbstractArray{::Number})
    FFTW.fft(a)
end
function fft(a::AbstractArray{T})
    T.([FFTW.fft(getindex.(a, i)) for i = eachindex(a[1])]...)
end

function dirconv(u::AbstractArray{S}, v::AbstractArray{T}, p=*, s=false) where {S,T}
    if length(v) > length(u)
        return dirconv(v, u, p, !s)
    end
    ret = fill(p(zero(S), zero(T)), size(u) .+ size(v) .- 1)
    for I = Iterators.product(axes(v)...)
        if v[I...] != zero(T)
            ret[[a .+ b .- 1 for (a, b) in zip(axes(u), size(v))]...] .+= map(u) do u
                s ? p(v[I...], u) : p(u, v[I...])
            end
        end
    end
    ret
end
function conv(u::AbstractArray, v::AbstractArray, p=*) where {S,T}
    if maximum(size(u)) < 4 || maximum(size(v)) < 4
        return dirconv(u, v, p)
    end

    n = length(u[1])
    if p == *
        r = [conv(u, getindex.(v, i)) for i = 1:n]
        map(r...) do v...
            SVector(v...)
        end
    elseif p == dot || p == :dot
        sum(conv.([getindex.(u, i) for i = 1:n], [getindex.(v, i) for i = 1:n]))
    elseif p == cross || p == :cross
        if n == 2
            conv(getindex.(u, 1), getindex.(v, 2)) - conv(getindex.(u, 2), getindex.(v, 1))
        elseif n == 3
            SVector{3}.(
                conv(getindex.(u, 2), getindex.(v, 3)) - conv(getindex.(v, 2), getindex.(u, 3)),
                conv(getindex.(u, 3), getindex.(v, 1)) - conv(getindex.(u, 1), getindex.(v, 3)),
                conv(getindex.(u, 1), getindex.(v, 2)) - conv(getindex.(u, 2), getindex.(v, 1))
            )
        else
            error("cross prod only applies in 2d/3d")
        end
    elseif p == :exterior
        map([conv(getindex.(u, i), v) for i = 1:n]...) do a...
            SVector{n}.(eachrow(hcat(a...)))
        end
    end

end

function conv(u::AbstractArray{S}, v::AbstractArray{T},) where {S<:Number,T<:Number}
    DSP.conv(u, v)
end