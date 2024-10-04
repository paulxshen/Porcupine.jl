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
    o, w = nn(o)
    w = eltype(a).(w)
    d = [isa(i, Number) ? 0 : (0:Int(step(i)):Int(last(i) - first(i))) for i in I]
    sum([w * a[(o .+ d)...] for (o, w) = zip(o, w)])

end
interp(a, I) = getindexf(a, I...)
Base.getindex(a::AbstractArray, i::AbstractFloat) = interp(a, [i])
Base.getindex(a::AbstractArray, i::AbstractFloat, j::AbstractFloat) = interp(a, [i, j])
Base.getindex(a::AbstractArray, i::AbstractFloat, j::AbstractFloat, k::AbstractFloat) = interp(a, [i, j, k])
Base.getindex(a::AbstractArray, v::AbstractVector{<:AbstractFloat}) = interp(a, v)