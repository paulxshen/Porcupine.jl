
function int(x::AbstractRange)
    i = int(first(x))
    d = int(step(x))
    j = int(last(x))
    d == 0 ? (i:j) : (i:d:j)
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

(x::Scalar)(args...) = x
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

function getbbox(a)
    lb = map(enumerate(size(a))) do (dim, n)
        for i = 1:n
            s = selectdim(a, dim, i)
            any(!iszero, s) && return i
        end
    end
    ub = map(enumerate(size(a))) do (dim, n)
        for i = n:-1:1
            s = selectdim(a, dim, i)
            any(!iszero, s) && return i
        end
    end
    hcat(lb, ub)
end

I2 = Matrix(I, 2, 2)
I3 = Matrix(I, 3, 3)