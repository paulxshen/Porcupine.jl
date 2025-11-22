
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
(a::AbstractArray)(I::AbstractVector{<:Integer}) = a[I]
(a::AbstractArray)(args...) = getindexf(a, args...)
(a::AbstractArray)(::Str) = a

(t::Tuple)(args::Vararg{<:Index}) = t[args...]
(t::Tuple)(::Str) = t
Base.Array(x) = x

function imnormal(a::AbstractArray{T,N}, d=1) where {T,N}
    n = map(1:N) do dims
        size(a, dims) == 1 && return 0
        -sum(diff(a; dims))
    end ./ d

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
function resize(a::AbstractArray{T,N}, sz::Union{AbstractArray{<:Integer},NTuple{N,<:Integer}}; inbound=false) where {T<:Union{Complex,AbstractFloat},N}
    _sz = Tuple(sz)
    sz = size(a)
    _sz == sz && return a
    for (dims, (n, _n)) = enumerate(zip(sz, _sz))
        if _n != n
            # s = eachslice(a; dims)
            v = map(1:_n) do i
                if inbound
                    v = @ignore_derivatives nn((i - 1) * (n - 1) / (_n - 1) + 1)
                else
                    v = @ignore_derivatives nn((i - T(0.5)) * n / _n + T(0.5))
                end
                sum(v) do (j, w)
                    j = clamp(j, 1, n)
                    w * selectdim(a, dims, j)
                    # w * s[j]
                end
            end
            p = collect(1:(N-1))
            @ignore_derivatives insert!(p, dims, N)
            a = permutedims(stack(v), p)
        end
    end
    @assert size(a) == _sz
    a
end

function resize(a::AbstractArray{T,N}, axs; approx=false) where {T<:Union{Complex,AbstractFloat},N}
    for (i, ax) = zip(1:N, axs)
        I = ifelse.(i .== (1:N), (ax,), (:))
        if approx
            I = map(I) do I
                I == (:) ? I : round.(Int, ax)
            end
        end
        a = getindexf.((a,), I...)
        a = permutedims(stack(a), ignore_derivatives() do
            insert!(collect(1:N-1), i, N)
        end)
    end
    a
end

unstack(a::AbstractArray{T,N}) where {T,N} = eachslice(a, dims=N)

function smooth(a::AbstractArray{T,N}) where {T,N}
    for dims = 1:N
        n = size(a, dims)
        a = (selectdim(a, dims, 1:n-1) + selectdim(a, dims, 2:n)) / 2
    end
    a
end
Base.step(v::AbstractVector) = v[2] - v[1]
