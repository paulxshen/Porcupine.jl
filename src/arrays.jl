
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
    for (d, m) = enumerate(Tuple(sz))
        n = size(a, d)
        m == n && continue
        # linear interpolation along d: blend of 2 gathers
        p, w = ignore_derivatives() do
            R = real(T)
            x = inbound ? [R((i - 1) * (n - 1) / (m - 1) + 1) for i = 1:m] : [(i - R(0.5)) * n / m + R(0.5) for i = 1:m]
            p = floor.(Int, x)
            p, copyto!(similar(a, R, ntuple(i -> i == d ? m : 1, N)), x - p)
        end
        I(j) = ntuple(i -> i == d ? clamp.(j, 1, n) : (:), N)
        a = (1 .- w) .* a[I(p)...] + w .* a[I(p .+ 1)...]
    end
    @assert size(a) == Tuple(sz)
    a
end

function resize(a::AbstractArray{T,N}, axs; approx=false) where {T<:Union{Complex,AbstractFloat},N}
    all(size(a) .== length.(axs)) && return a
    for (i, ax) = zip(1:N, axs)
        I = ifelse.(i .== (1:N), (ax,), (:))
        if approx
            I = map(I) do I
                I == (:) ? I : round.(Int, ax)
            end
        end
        a = getindexf.((a,), I...)
        a = permutedims(stack(a), ignore_derivatives() do
            insert!(collect(1:(N-1)), i, N)
        end)
    end
    a
end

unstack(a::AbstractArray{T,N}) where {T,N} = eachslice(a, dims=N)

smooth(a::AbstractArray) = _centroids(a, 1:ndims(a))
Base.step(v::AbstractVector) = v[2] - v[1]
