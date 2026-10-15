
_downsample(f, a, rs) = [f(a[getindex.(rs, Tuple(I))...]) for I = CartesianIndices(length.(rs))]
_ratio(r::Int, d) = r
_ratio(r, d) = r[d]
function downsample(f, a, ratio::Union{Int,AbstractVector{Int},NTuple{N,Int}}) where {N}
    ratio == 1 && return a
    _downsample(f, a, ntuple(ndims(a)) do d
        r = _ratio(ratio, d)
        [i:i+r-1 for i = 1:r:size(a, d)-r+1]
    end)
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
_blocks(s) = range.(cumsum(s) .- s .+ 1, cumsum(s))
function downsample(f, a, spacings)
    spacings = _downvec.(spacings, size(a))
    @assert all(size(a) .== int(sum.(spacings)))
    _downsample(f, a, Tuple(_blocks.(spacings)))
end
downsample(a, v) = downsample(mean, a, v)

_upvec(r::Real, len) = fill(Int(r), Int(len))
_upvec(v::AbstractArray, len) = int(vec(v))
_repidx(s) = [i for (i, k) = enumerate(s) for _ = 1:k]
upsample(a, spacings) = a[@ignore_derivatives(_repidx.(_upvec.(spacings, size(a))))...]
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