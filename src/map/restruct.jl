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

# _T = Union{Number,Str}
# function rmap(f, d::Map, T=_T)
#     isa(d, T) && return f(d)
#     vmap(d) do v
#         rmap(f, v, T)
#     end
# end
# function rmap(f, a::ArrayLike, T=_T)
#     isa(a, T) && return f(a)
#     rmap.((f,), a, (T,))
# end
# function rmap(f, x, T=_T)
#     if isa(x, T)
#         return f(x)
#     elseif isempty(propertynames(x))
#         return x
#     end
#     xs, re = functor(x)
#     re(rmap(f, xs, T))
# end
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

rmap(f, x::Scalar) = f(x)
function rmap(f, d::Map)
    vmap(d) do v
        rmap(f, v)
    end
end
function rmap(f, a::ArrayLike)
    rmap.((f,), a)
end
function rmap(f, x)
    if isempty(propertynames(x))
        return x
    end
    xs, re = functor(x)
    re(rmap(f, xs))
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
