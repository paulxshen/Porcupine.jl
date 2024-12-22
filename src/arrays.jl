function nn(i)
    p = ignore_derivatives() do
        floor.(Int, i)
    end
    q = ignore_derivatives() do
        ceil.(Int, i)
    end
    aw = [(j, prod(1 - abs.(i - j))) for j = ignore_derivatives() do
        Base.product(unique.(zip(p, q))...)
    end]
    return getindex.(aw, 1), getindex.(aw, 2)
end
function int(x::AbstractRange)
    i = int(first(x))
    d = int(step(x))
    j = int(last(x))
    d == 0 ? (i:j) : (i:d:j)
end

function setindexf!(a, v, I...)
    o = first.(I)
    os, ws = nn(o)
    ws = eltype(a).(ws)
    for (_o, w) = zip(os, ws)
        a[int.(_o - o .+ I)...] += w * v
    end
end

function getindexf(a, I...)
    o = first.(I)
    os, ws = nn(o)
    ws = eltype(a).(ws)
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

(x::Union{Number,Nothing})(args...) = x
(a::AbstractArray)(args::Vararg{<:Index}) = a[args...]
# ::Vararg{<:Union{Integer,Colon,AbstractRange}}
(a::AbstractArray)(args...) = getindexf(a, args...)
(a::AbstractArray)(::Text) = a

(t::Tuple)(args::Vararg{<:Index}) = t[args...]
(t::Tuple)(::Text) = t