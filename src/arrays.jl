function nn(i; approx=false)
    p = ignore_derivatives() do
        floor.(Int, i)
    end
    q = ignore_derivatives() do
        ceil.(Int, i)
    end
    # p == q && return ([p], [1])

    aw = [(j, prod(1 - abs.(i - j))) for j = @ignore_derivatives Base.product(unique.(zip(p, q))...)]
    if approx
        j1, w1 = aw[1]
        j2, w2 = aw[end]
        w = w1 + w2
        w1 /= w
        w2 /= w
        [j1, j2], [w1, w2]
    else
        getindex.(aw, 1), getindex.(aw, 2)
    end
end
function int(x::AbstractRange)
    i = int(first(x))
    d = int(step(x))
    j = int(last(x))
    d == 0 ? (i:j) : (i:d:j)
end

function _setindexf!(T, a, v, I...; approx)
    o = first.(I)
    os, ws = nn(o; approx)
    for (_o, w) = zip(os, ws)
        w = T(w)
        a[int.(_o - o .+ I)...] += w * v
    end
end
function setindexf!(a::AbstractArray{T}, v, I...; approx=false) where {T}
    _setindexf!(T, a, v, I...; approx)
end

function getindexf(a, I...; approx=false)
    o = first.(I)
    os, ws = nn(o; approx)
    T = eltype(a)
    if !(T <: Integer)
        ws = T.(ws)
    end
    N = ndims(a)

    v = [getindex.(os, i) for i = 1:N]
    l = 1 - minimum.(v)
    r = maximum.(v) + last.(I) - first.(I) - size(a)
    l, r = int.(max.(l, 0)), int.(max.(r, 0))

    if any(l .> 0) || any(r .> 0)
        _a = pad(a, :replicate, l, r)
    else
        _a = a
    end
    sum([w * _a[ignore_derivatives() do
        int.((_o - o + l) .+ I)
    end...] for (_o, w) = zip(os, ws)])
end

getindexs(s::Number, i) = s * i
getindexs(s::AbstractVector, i) = i == 0 ? 0 : getindexf(s, i)

function crop(a, l, r=l)
    if all(l .== 0) && all(r .== 0)
        return a
    end
    N = ndims(a)
    start = l + ones(Int, N)
    stop = -r + size(a)
    getindexf(a, [i:j for (i, j) in zip(start, stop)]...)
    # _getindexf(a, range.())
end
crop(a, lr::AbstractMatrix) = crop(a, lr[:, 1], lr[:, 2])

Base.diff(x::Number; kw...) = 0

(x::Union{Number,Nothing})(args...) = x
(a::AbstractArray)(args::Vararg{<:Index}) = a[args...]
(a::AbstractArray)(args...) = getindexf(a, args...)
(a::AbstractArray)(::Text) = a

(t::Tuple)(args::Vararg{<:Index}) = t[args...]
(t::Tuple)(::Text) = t
Base.Array(x) = x

function imnormal(a)
    N = ndims(a)
    n = map(1:N) do dims
        -sum(diff(a; dims))
    end

    Z = norm(n)
    if Z > 1.0f-4
        n /= Z
    else
        n *= 0
    end
    n
end
# sz = size(d)
# dmin, dmax = extrema(d)
# if !(dmin + TOL < 0 < dmax - TOL)
#     sum(d) / size(d, dims)
# else
#     global _aa = _a
#     volume(_aa) |> display
#     error()
#     dm = d .* (d .< 0)
#     dp = d .* (d .> 0)
#     centers = sum.(map((dm, dp)) do m
#         m = abs.(m)
#         m .* Tuple.(CartesianIndices(m))
#     end) ./ abs.(sum.((dm, dp)))
#     # @show centers
#     distm, distp = norm.(centers .- (sz / 2 + 0.5,))
#     @show distm, distp
#     if distm ≈ distp
#         0
#     elseif distm < distp
#         sum(dm) / size(dm, dims)
#     else
#         sum(dp) / size(dp, dims)
#     end
# end