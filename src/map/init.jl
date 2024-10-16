Base.map(f::Function, s::AbstractSet) = [f(x) for x = s]

namedtuple(d::AbstractDict) = NamedTuple(Pair.(Symbol.(keys(d)), values(d)))
namedtuple(ps::AbstractVector{<:Pair}) = NamedTuple([Symbol(p[1]) => p[2] for p in ps])
namedtuple(x) = NamedTuple(x)

function dict(K, V, ps)
    r = OrderedDict{K,V}()
    for (k, v) = ps
        r[k] = v
    end
    r
end

function dict(ps::Vector{<:Pair{K,V}}) where {K,V}
    dict(K, V, ps)
end
dict(x::NamedTuple) = dict(pairs(x))
function dict(ps)
    dict(Any, Any, ps)
end



function ChainRulesCore.rrule(::typeof(namedtuple), ps)
    # @show ps
    y = namedtuple(ps)
    function NamedTuple_pullback(ȳ)
        NoTangent(), collect(pairs(ȳ))
    end
    return y, NamedTuple_pullback
end

function ChainRulesCore.rrule(::Type{Pair}, a::Symbol, b)
    y = Pair(a, b)
    function Pair_pullback(ȳ)
        NoTangent(), NoTangent(), ȳ[2]
    end
    return y, Pair_pullback
end

# group(d, k) = namedtuple([_k => d[_k] for _k in ignore_derivatives() do
#     filter(_k -> startswith(string(_k), string(k)), keys(d))
# end])

# Base.NamedTuple(v::AbstractVector{<:Tuple{<:Symbol,<:Any}}) = NamedTuple(Pair.(v))
# namedtuple(x) = NamedTuple(x)
# Base.Pair(t::Tuple) = Pair(t[1], t[2])
# Base.Pair(t::Vector) = Pair(t[1], t[2])
# namedtuple(x) = NamedTuple(Pair.(x))
# function ChainRulesCore.rrule(::typeof(namedtuple), v)
#     y = namedtuple(v)
#     function namedtuple_pullback(ȳ)
#         # NoTangent(), collect(pairs(ȳ))
#         # NoTangent(), (keys(ȳ), collect(ȳ))
#         NoTangent(), collect(collect.(pairs(ȳ)))
#     end
#     return y, namedtuple_pullback
# end
# function ChainRulesCore.rrule(::typeof(NamedTuple), d::AbstractDict{K,V}) where {K,V}
#     # y = NamedTuple(pairs(d))
#     y = NamedTuple(Pair.(Symbol.(keys(d)), values(d)))
#     function NamedTuple_pullback(ȳ)
#         T = typeof(d)
#         # NoTangent(), T([K(k) => V(v) for (k, v) = pairs(ȳ)])
#         NoTangent(), OrderedDict(pairs(ȳ))
#     end
#     return y, NamedTuple_pullback
# end
# _f_by_key(f, x, y) =
#     map(keys(x)) do k
#         k => begin
#             if isa(x[k], Map)
#                 f(x[k], y[k])
#             else
#                 f.(x[k], y[k])
#             end
#         end
#     end


# function _f2(T, f, x, y)
#     if issubset(keys(y), keys(x))
#         return T(_f_by_key(f, x, y))
#     end
#     if issubset(keys(x), keys(y))
#         return T(_f_by_key((x, y) -> f(y, x), y, x))
#     end
#     # println(keys(x))
#     # println(keys(y))
#     T(_f_by_val(f, x, values(y)))
# end


# function apply(f::Function, d::Map)
#     fmap(f, d)
# end

# unroll(v::AbstractVector, ks...) = v[1:length(ks)]
# unroll(d::Map, ks...) = d.(ks)




# function ChainRulesCore.rrule(::typeof(NamedTuple), ps::AbstractVector{<:Pair})
#     y = namedtuple(ps)
#     function NamedTuple_pullback(ȳ)
#         NoTangent(), collect(pairs(ȳ))
#     end
#     return y, NamedTuple_pullback
# end