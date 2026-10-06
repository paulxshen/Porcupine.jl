Base.map(f::Func, x::AbstractDict) = map(f, _values(x))

function kvmap(f::Func, x::NamedTuple)
    # namedtuple([f(k, v) for (k, v) = pairs(x)])
    namedtuple([f(k, x[k]) for k = keys(x)])
end
function kvmap(f::Func, x::AbstractDict)
    dict([f(k, x[k]) for k = keys(x)])
    # dict([f(k, v) for (k, v) = pairs(x)])
end
vmap(f, x) = kvmap((k, v) -> k => f(v), x)
kmap(f, x) = kvmap((k, v) -> f(k) => v, x)

# broadcast(::typeof(+), args...) = Base.broadcast(+, filter(!isempty, args)...)
# broadcast(args...) = Base.broadcast(args...)
function _vmap(f::Func, x, y)
    isempty(x) && return y
    isempty(y) && return x
    # tuple.(keys(x), broadcast(f, _values(x), _values(y)))
    Pair.(keys(x), broadcast(f, _values(x), _values(y)))
end
vmap(f::Func, x::NamedTuple, y) = namedtuple(_vmap(f, x, y))
vmap(f::Func, x::AbstractDict, y) = dict(_vmap(f, x, y))

fmap(f, x::AbstractArray{<:Number}) = f(x)
function fmap(f, d::Map)
    vmap(d) do v
        fmap(f, v)
    end
end
function fmap(f, a::ArrayLike)
    fmap.((f,), a)
end
function fmap(f, x)
    if isempty(propertynames(x))
        return x
    end
    xs, re = functor(x)
    re(fmap(f, xs))
end

function rmap(f, T, c::S) where S
    S<:T && return f(c)
    S<:Union{AbstractArray,Tuple} && return rmap.((f,), (T,), c)
    S<:NamedTuple && return NamedTuple(keys(c) .=> rmap.((f,), (T,), _values(c)))
    S<:AbstractDict && return OrderedDict(keys(c) .=> rmap.((f,), (T,), _values(c)))
    c
end

leaves(x) = [x]
function leaves(d::Union{Map,AbstractVector{<:AbstractArray}})
    reduce(vcat, leaves.(_values(d)))
end

flatten(x::Scalar) = [x]
function flatten(c)
    reduce(vcat, flatten.(_values(c)))
end

sortkeys(d::NamedTuple) = namedtuple([k => sortkeys(d[k]) for k in sort(keys(d))])
sortkeys(d::AbstractDict) = dict([k => sortkeys(d[k]) for k in sort(keys(d))])
sortkeys(x) = x
