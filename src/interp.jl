function nn(i)
    p = floor.(i)
    q = ceil.(i)
    aw = [(j, prod(1 - abs.(i - j))) for j = Base.product([p[i] == q[i] ? (p[i],) : (p[i], q[i]) for i = 1:length(i)]...)]
    aw = filter(x -> x[2] > 0, aw)
    return getindex.(aw, 1), getindex.(aw, 2)
end
# function interp(a, i, with=false)
#     p = floor(i)
#     q = ceil(i)
#     # sum([a[j...] * prod(1 - abs.(i - j)) for j = Base.product(zip(p, q)...)])
#     # sum([a[j...] * prod(1 - abs.(i - j)) for j = Base.product([unique((p[i], q[i])) for i = 1:length(i)]...)])
#     aw = [(a[j...], prod(1 - abs.(i - j))) for j = Base.product([p[i] == q[i] ? (p[i],) : (p[i], q[i]) for i = 1:length(i)]...)]
#     if with
#     end
#     sum([a * w for (a, w) in aw])
# end
# Base.getindex(a::AbstractArray, i...) = interp(a, i)

function setindexf!(a, v, I...)
    o = first.(I)
    o, w = nn(o)
    w = eltype(a).(w)
    d = [isa(i, Number) ? 0 : (0:Int(step(i)):Int(last(i) - first(i))) for i in I]
    for (o, w) = zip(o, w)
        a[(o .+ d)...] = w * v
    end

end
function getindexf(a, I...)
    o = first.(I)
    os, ws = nn(o)
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

    ws = eltype(a).(ws)
    d = [isa(i, Number) ? 0 : (0:Int(step(i)):Int(last(i) - first(i))) for i in I]
    sum([w * _a[(o + l + d)...] for (o, w) = zip(os, ws)])

end

function crop(a, l, r=l)
    if all(l .== 0) && all(r .== 0)
        return a
    end
    getindexf(a, range.(l .+ ones(ndims(a)), -r .+ size(a) .+ 0.001)...)
end
crop(a, lr::AbstractMatrix) = crop(a, lr[:, 1], lr[:, 2])

interp(a, I) = getindexf(a, I...)
Base.getindex(a::AbstractArray, i::AbstractFloat) = interp(a, [i])
Base.getindex(a::AbstractArray, i::AbstractFloat, j::AbstractFloat) = interp(a, [i, j])
Base.getindex(a::AbstractArray, i::AbstractFloat, j::AbstractFloat, k::AbstractFloat) = interp(a, [i, j, k])
Base.getindex(a::AbstractArray, v::AbstractVector{<:AbstractFloat}) = interp(a, v)