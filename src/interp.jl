function nn(i)
    p = ignore_derivatives() do
        floor.(Int, i)
    end
    q = ignore_derivatives() do
        ceil.(Int, i)
    end
    aw = [(j, prod(1 - abs.(i - j))) for j = Base.product([p[i] == q[i] ? (p[i],) : (p[i], q[i]) for i = 1:length(i)]...)]
    aw = filter(x -> x[2] > 0, aw)
    return getindex.(aw, 1), getindex.(aw, 2)
end

function setindexf!(a, v, I...)
    o = first.(I)
    os, ws = nn(o)
    ws = eltype(a).(ws)
    d = [isa(i, Number) ? 0 : (0:Int(step(i)):round(Int, last(i) - first(i))) for i in I]
    for (o, w) = zip(os, ws)
        a[(o .+ d)...] = w * v
    end
end

Base.Int(x::AbstractRange) = Int(first(x)):Int(step(x)):Int(last(x))
function getindexf(a, I...)
    o = first.(I)
    os, ws = nn(o)
    ws = eltype(a).(ws)
    N = ndims(a)

    v = [getindex.(os, i) for i = 1:N]
    l = 1 - minimum.(v)
    r = maximum.(v) + last.(I) - first.(I) - size(a)
    l, r = Int.(max.(l, 0)), Int.(max.(r, 0))

    if any(l .> 0) || any(r .> 0)
        _a = pad(a, :replicate, l, r)
    else
        _a = a
    end
    sum([w * _a[Int.((_o - o + l) .+ I)...] for (_o, w) = zip(os, ws)])
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

# interp(a, I) = getindexf(a, I...)
# Base.getindex(a::AbstractArray, i::AbstractFloat) = interp(a, [i])
# Base.getindex(a::AbstractArray, i::AbstractFloat, j::AbstractFloat) = interp(a, [i, j])
# Base.getindex(a::AbstractArray, i::AbstractFloat, j::AbstractFloat, k::AbstractFloat) = interp(a, [i, j, k])
# Base.getindex(a::AbstractArray, v::AbstractVector{<:AbstractFloat}) = interp(a, v)


