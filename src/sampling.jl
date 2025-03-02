
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

downsample_by_range(f, a::AbstractArray, ranges; kw...) = downsample_by_range(f, (a,), ranges; kw...)
function downsample_by_range(f, as::Tuple, ranges, ; withindex=false)
    map(Base.product(ranges...)) do I
        v = map(as) do a
            a(I...)
        end
        withindex ? f(v..., I) : f(v...)
    end
end
# function downsample_by_range(f, ranges, a::AbstractArray{T}, as...) where {T}
#     downsample_by_range(f, T, a, ranges, as...)
# end

_downvec(r::Real, len) = fill(Int(r), Int(len / r))
_downvec(v::AbstractArray, len) = int(vec(v))
function downsample(f, a, spacings)
    spacings = _downvec.(spacings, size(a))
    @assert all(size(a) .== int(sum.(spacings)))
    sz = Tuple(length.(spacings))
    stops = cumsum.(vec.(spacings))
    starts = stops - spacings + 1
    [f(a[range.(getindex.(starts, Tuple(I)), getindex.(stops, Tuple(I)))...]) for I = CartesianIndices(sz)]
end
downsample(a, v) = downsample(mean, a, v)

_upvec(r::Real, len) = fill(Int(r), Int(len))
_upvec(v::AbstractArray, len) = int(vec(v))
function upsample(a, spacings)
    spacings = _upvec.(spacings, size(a))
    sz = size(a)
    stops = cumsum.(vec.(spacings))
    starts = stops - spacings + 1
    r = zeros(eltype(a), Tuple(sum.(spacings)))
    for I = CartesianIndices(sz)
        r[range.(getindex.(starts, Tuple(I)), getindex.(stops, Tuple(I)))...] .= a[I]

    end
    r
end
# function upsample(a, ratio)
#     A = zeros(complex(eltype(a)), ratio * size(a))
#     A[Base.OneTo.(size(a))...] .= fft(a)
#     ifft(A)
# end


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