Base.map(f::Function, s::AbstractSet) = [f(x) for x = s]


leaves(x) = [x]
function leaves(d::Union{Dictlike,AbstractVector{<:AbstractArray}})
    reduce(vcat, leaves.(values(d)))
end

flatten(x::Union{Number,String,Symbol}) = [x]
function flatten(c)
    reduce(vcat, flatten.(values(c)))
end

function approx_getindex(d, k)
    for _k in keys(d)
        if k ≈ _k
            return d[_k]
        end
    end
    error("Key not found even approximately")
end


Base.haskey(a::NamedTuple, k::String) = false

struct Null end
null = Null()

recursive_getindex(d, k) = null
function recursive_getindex(d::Dictlike, k)
    haskey(d, k) && return d[k]
    for v = values(d)
        v = recursive_getindex(v, k)
        if v != null
            return v
        end
    end
    null
end

function _getindex(d, k)
    if haskey(d, k)
        return d[k]
    end
end

Base.getproperty(d::AbstractDict, k::Symbol) = hasproperty(d, k) ? getfield(d, k) : d(k)

function (d::Dictlike)(k::Int)
    haskey(d, k) && return d[k]
    if k > 0
        return values(d)[k]
    end
end

function (d::Dictlike)(k::Symbol)
    r = recursive_getindex(d, k)
    r != null && return r
    recursive_getindex(d, string(k))
end

function (d::Dictlike)(k::String)
    r = recursive_getindex(d, k)
    r != null && return r
    recursive_getindex(d, Symbol(k))
end

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

function dict(ps)
    dict(Any, Any, ps)
end



function dict(v::NamedTuple)
    # dict(pairs(v))
    v
end

Ops = Union{typeof.((+, -, *, /))...}
Base.broadcastable(x::AbstractDict) = values(x)
Base.broadcastable(x::SortedDict) = values(x)
Base.broadcastable(x::OrderedDict) = values(x)
Base.broadcastable(x::NamedTuple) = collect(x)

_T(T) = T
_T(::Type{T}) where {T<:NamedTuple} = namedtuple

_f_by_val(f, x, y) =
    broadcast(keys(x), values(y)) do k, v
        k => begin
            if isa(x[k], Dictlike)
                f(x[k], v)
            else
                f.(x[k], v)
            end
        end
    end

_f_by_key(f, x, y) =
    map(keys(x)) do k
        k => begin
            if isa(x[k], Dictlike)
                f(x[k], y[k])
            else
                f.(x[k], y[k])
            end
        end
    end


function _f2(T, f, x, y)
    if issubset(keys(y), keys(x))
        return T(_f_by_key(f, x, y))
    end
    if issubset(keys(x), keys(y))
        return T(_f_by_key((x, y) -> f(y, x), y, x))
    end
    # println(keys(x))
    # println(keys(y))
    T(_f_by_val(f, x, values(y)))
end

_f(f, x::T, y) where {T<:NamedTuple} = namedtuple(_f_by_val(f, x, y))
_f(f, x::T, y) where {T<:AbstractDict} = dict(_f_by_val(f, x, y))
_f(f, x::T, y::S) where {T<:NamedTuple,S<:Dictlike} = _f2(namedtuple, f, x, y)
_f(f, x::T, y::S) where {T<:AbstractDict,S<:Dictlike} = _f2(dict, f, x, y)

# function Base.:+(x::Dictlike, y::Dictlike)
#     if isempty(x)
#         return y
#     end
#     _f(+, x, y)
# end
# Base.:+(x, y::Dictlike) = y + x

Base.:+(x::T, y) where {T<:Dictlike} = _f(+, x, y)
Base.:+(x, y::T) where {T<:Dictlike} = y + x
Base.:+(x::S, y::T) where {S<:Dictlike,T<:Dictlike} = _f(+, x, y)

Base.:*(x::T, y) where {T<:Dictlike} = _f(*, x, y)
Base.:*(x, y::T) where {T<:Dictlike} = y * x
Base.:*(x::T, y::S) where {S<:Dictlike,T<:Dictlike} = _f(*, x, y)

Base.:-(x::T,) where {T<:Dictlike} = 0 - x
Base.:-(x::T, y) where {T<:Dictlike} = _f(-, x, y)
Base.:-(x, y::T) where {T<:Dictlike} = _f((x, y) -> y - x, y, x) #- (y - x)
Base.:-(x::T, y::S) where {S<:Dictlike,T<:Dictlike} = _f(-, x, y)


Base.:/(x::T, y) where {T<:Dictlike} = _f(/, x, y)
Base.:/(x, y::T) where {T<:Dictlike} = _f((x, y) -> y / x, y, x)
Base.:/(x::T, y::S) where {S<:Dictlike,T<:Dictlike} = _f(/, x, y)

# ZeroTangent
Base.:+(x::ZeroTangent, y::Dictlike) = y
Base.:+(x::Dictlike, y::ZeroTangent) = x

fmap(f, x::Number) = f(x)
fmap(f, x::AbstractArray{<:Number}) = f(x)
fmap(f, x::AbstractArray) = fmap.((f,), x)
function fmap(f, d::Dictlike)
    dict([k => fmap(f, d[k]) for k in keys(d)])
end

# function fmap(f, x::T, types=[]) where {T}
function fmap(f, x::T) where {T}
    # if isempty(propertynames(x)) || T in types
    if isempty(propertynames(x))
        return f(x)
    end
    xs, re = functor(x)
    # re(fmap.((f,), xs, (types,)))
    re(fmap.((f,), xs))
end

function apply(f::Function, d::Dictlike)
    fmap(f, d)
end

unroll(v::AbstractVector, ks...) = v[1:length(ks)]
unroll(d::Dictlike, ks...) = d.(ks)

namedtuple(d::AbstractDict) = NamedTuple(Pair.(Symbol.(keys(d)), values(d)))
namedtuple(ps::AbstractVector{<:Pair}) = NamedTuple([Symbol(p[1]) => p[2] for p in ps])
namedtuple(x) = NamedTuple(x)


# function ChainRulesCore.rrule(::typeof(NamedTuple), ps::AbstractVector{<:Pair})
#     y = namedtuple(ps)
#     function NamedTuple_pullback(ȳ)
#         NoTangent(), collect(pairs(ȳ))
#     end
#     return y, NamedTuple_pullback
# end

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

group(d, k) = namedtuple([_k => d[_k] for _k in ignore_derivatives() do
    filter(_k -> startswith(string(_k), string(k)), keys(d))
end])

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