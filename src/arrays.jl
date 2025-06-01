
function int(x::AbstractRange)
    i = int(first(x))
    d = int(step(x))
    j = int(last(x))
    d == 0 ? (i:j) : (i:d:j)
end


Base.min(a::AbstractArray, b::AbstractArray) = min.(a, b)
Base.max(a::AbstractArray, b::AbstractArray) = max.(a, b)

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


(x::Scalar)(args...) = x
(a::AbstractArray)(args::Vararg{<:Index}) = a[args...]
(a::AbstractArray)(args...) = getindexf(a, args...)
(a::AbstractArray)(::Str) = a

(t::Tuple)(args::Vararg{<:Index}) = t[args...]
(t::Tuple)(::Str) = t
Base.Array(x) = x

function imnormal(a::AbstractArray{T,N}) where {T,N}
    n = map(1:N) do dims
        size(a, dims) == 1 && return 0
        -sum(diff(a; dims))
    end

    Z = norm(n)
    Z > 0 && return n / Z
    n
end
function improj(a)
    N = ndims(a)
    g = centroids.(diff.([a], 1:N), [[j for j = 1:N if j != i] for i = 1:N])
    P = sum.(g * permutedims(g, (2, 1)))
    tr(P) > 0 && return P / tr(P)
    P
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

function resize(a::AbstractArray{T,N}, sz) where {T,N}
    if T <: Integer
        F = Float32
    else
        F = T
    end
    for (dims, (_n, n)) = enumerate(zip(size(a), sz))
        if _n != n
            s = eachslice(a; dims)
            v = map(1:n) do i
                v = @ignore_derivatives nn((i - F(0.5)) * _n / n + F(0.5))
                sum(v) do (j, w)
                    j = max(1, j)
                    j = min(j, _n)
                    # w * selectdim(a, dims, j)
                    w * s[j]
                end
            end
            p = collect(1:N-1)
            @ignore_derivatives insert!(p, dims, N)
            a = permutedims(stack(v), p)
        end
    end
    a
end