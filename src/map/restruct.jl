Base.map(f::Function, x::AbstractDict) = map(f, values(x))
function kmap(f, x::NamedTuple)
    namedtuple([k => f(x[k]) for k in keys(x)])
end
function kmap(f, x::AbstractDict)
    dict([k => f(x[k]) for k in keys(x)])
end

# broadcast(::typeof(+), args...) = Base.broadcast(+, filter(!isempty, args)...)
# broadcast(args...) = Base.broadcast(args...)
function _kmap(f::Function, x, y)
    isempty(x) && return y
    isempty(y) && return x
    Pair.(keys(x), broadcast(f, values(x), values(y)))
end
kmap(f::Function, x::NamedTuple, y) = namedtuple(_kmap(f, x, y))
kmap(f::Function, x::AbstractDict, y) = dict(_kmap(f, x, y))

function fmap(f, d::Map, T=Union{})
    isa(d, T) && return f(d)
    kmap(d) do v
        fmap(f, v, T)
    end
end
function fmap(f, a::Container, T=Union{})
    isa(a, T) && return f(a)
    fmap.((f,), a, (T,))
end
function fmap(f, x, T=Union{})
    if isa(x, Union{Number,Text,T}) || isempty(propertynames(x))
        return f(x)
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
