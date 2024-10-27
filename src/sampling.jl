
function downsample(f, a, ratio::Union{Int,AbstractVector{Int},NTuple{N,Int}}) where {N}
    ratio == 1 && return a
    [
        begin
            I = Tuple(I)
            start = 1 + ratio .* (I - 1)
            f(a[range.(start, start + ratio - 1)...])
        end for I = CartesianIndices(Tuple(size(a) .÷ ratio))
    ]
end

_spacings(r::Real, len) = fill(Int(r), Int(len / r))
_spacings(v, len) = vec(v)
function downsample(f, a, spacings)
    spacings = _spacings.(spacings, size(a))
    @assert all(size(a) .== sum.(spacings))
    sz = Tuple(length.(spacings))
    stops = cumsum.(vec.(spacings))
    starts = stops - spacings + 1
    [f(a[range.(getindex.(starts, Tuple(I)), getindex.(stops, Tuple(I)))...]) for I = CartesianIndices(sz)]
end
downsample(a, ratio) = downsample(mean, a, ratio)

function upsample(a, ratio)
    A = zeros(complex(eltype(a)), ratio * size(a))
    A[Base.OneTo.(size(a))...] .= fft(a)
    ifft(A)
end

function indexof(x, ticks)
    i = findfirst(>=(x), ticks)
    a = i == 1 ? 0 : ticks[i-1]
    b = ticks[i]
    i - 1 + (x - a) / (b - a)
end

v2i(x, dx::Real) = x / dx
v2i(x, deltas) = v2i.(x, deltas)
v2i(x, deltas::AbstractArray{<:Real}) = indexof(x, cumsum(deltas))

# i2v(i, dx::Real) = (i - 0.5) * dx
# i2v(i, deltas) = i2v.(i, deltas)
# function i2v(i, deltas::AbstractArray{<:Real})
#     a = floor(i - 0.5)
#     res = (i - 0.5 - a) * deltas[floor(i)]
#     if floor(i) > 1
#         res += sum(deltas[1:i-1])
#     end
#     res
# end