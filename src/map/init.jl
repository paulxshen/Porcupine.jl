Base.map(f::Func, s::AbstractSet) = [f(x) for x = s]

# namedtuple(d::AbstractDict) = NamedTuple(Pair.(Symbol.(keys(d)), values(d)))
# namedtuple(ps::AbstractVector{<:Pair}) = NamedTuple([Symbol(p[1]) => p[2] for p in ps])

dict() = OrderedDict()
function dict(K, V, kvs)
    r = OrderedDict{K,V}()
    for (k, v) = kvs
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



namedtuple(x) = NamedTuple(x)
namedtuple(d::AbstractDict) = NamedTuple(Pair.(Symbol.(keys(d)), values(d)))
function ChainRulesCore.rrule(::typeof(namedtuple), ps)
    # @show ps
    y = namedtuple(ps)
    function NamedTuple_pullback(ȳ)
        NoTangent(), collect(pairs(ȳ))
    end
    return y, NamedTuple_pullback
end

for T = (:Str, :Number, :AbstractFloat)
    @eval function ChainRulesCore.rrule(::Type{Pair}, a::$T, b)
        y = Pair(a, b)
        function Pair_pullback(ȳ)
            NoTangent(), NoTangent(), ȳ[2]
        end
        return y, Pair_pullback
    end
end

regex(args...) = @ignore_derivatives Regex(args...)
