Base.map(f::Func, x::AbstractDict) = map(f, values(x))

function kvmap(f::Func, x::NamedTuple)
    # namedtuple([f(k, v) for (k, v) = pairs(x)])
    namedtuple([f(k, x[k]) for k = keys(x)])
end
function kvmap(f::Func, x::AbstractDict)
    dict([f(k, x[k]) for k = keys(x)])
    # dict([f(k, v) for (k, v) = pairs(x)])
end
vmap(f::Func, x::NamedTuple) = kvmap((k, v) -> k => f(v), x)
vmap(f::Func, x::AbstractDict) = kvmap((k, v) -> k => f(v), x)

# broadcast(::typeof(+), args...) = Base.broadcast(+, filter(!isempty, args)...)
# broadcast(args...) = Base.broadcast(args...)
function _vmap(f::Func, x, y)
    isempty(x) && return y
    isempty(y) && return x
    Pair.(keys(x), broadcast(f, values(x), values(y)))
end
vmap(f::Func, x::NamedTuple, y) = namedtuple(_vmap(f, x, y))
vmap(f::Func, x::AbstractDict, y) = dict(_vmap(f, x, y))

_T = Union{Number,Str}
function fmap(f, d::Map, T=_T)
    isa(d, T) && return f(d)
    vmap(d) do v
        fmap(f, v, T)
    end
end
function fmap(f, a::Container, T=_T)
    isa(a, T) && return f(a)
    fmap.((f,), a, (T,))
end
function fmap(f, x, T=_T)
    if isa(x, T)
        return f(x)
    elseif isempty(propertynames(x))
        return x
    end
    xs, re = functor(x)
    re(fmap(f, xs, T))
end

leaves(x) = [x]
function leaves(d::Union{Map,AbstractVector{<:AbstractArray}})
    reduce(vcat, leaves.(values(d)))
end

flatten(x::Union{Number,String,Symbol}) = [x]
function flatten(c)
    reduce(vcat, flatten.(values(c)))
end

sortkeys(d::NamedTuple) = namedtuple([k => sortkeys(d[k]) for k in sort(keys(d))])
sortkeys(d::AbstractDict) = dict([k => sortkeys(d[k]) for k in sort(keys(d))])
sortkeys(x) = x
