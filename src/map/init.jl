Base.map(f::Func, s::AbstractSet) = [f(x) for x = s]

# namedtuple(d::AbstractDict) = NamedTuple(Pair.(Symbol.(keys(d)), _values(d)))
# namedtuple(ps::AbstractVector{<:Pair}) = NamedTuple([Symbol(p[1]) => p[2] for p in ps])
dict(kvs) = OrderedDict(kvs)
dict(d::NamedTuple) = dict(keys(d) .=> _values(d))
# function dict(ps::Vector{<:Pair{K,V}}) where {K,V}
#     dict(K, V, ps)
# end
# dict(x::NamedTuple) = dict(pairs(x))
# function dict(kvs)
#     OrderedDict(kvs)
# end
function ChainRulesCore.rrule(::typeof(dict), kvs)
    y = dict(kvs)
    function pb(ȳ)
        NoTangent(), collect(pairs(ȳ))
    end
    return y, pb
end

namedtuple(x) = NamedTuple(x)
namedtuple(kvs::AbstractVector) = NamedTuple([Symbol(kv[1]) => kv[2] for kv in kvs])
# namedtuple(d::AbstractDict) = NamedTuple(tuple.(Symbol.(keys(d)), _values(d)))
namedtuple(d::AbstractDict) = NamedTuple(Symbol.(keys(d)) .=> _values(d))

function ChainRulesCore.rrule(::typeof(namedtuple), ps)
    y = namedtuple(ps)
    function pb(ȳ)
        NoTangent(), collect(pairs(ȳ))
    end
    return y, pb
end

for T = (:Str, :Number, :AbstractFloat)
    @eval function ChainRulesCore.rrule(::Type{Pair}, a::$T, b)
        y = Pair(a, b)
        function pb(ȳ)
            NoTangent(), NoTangent(), ȳ[2]
        end
        return y, pb
    end
end

regex(args...) = @ignore_derivatives Regex(args...)
