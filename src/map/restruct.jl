Base.map(f::Function, x::AbstractDict) = map(f, values(x))
function fmap(f, d::NamedTuple, type=Union{})
    namedtuple([k => fmap(f, d[k], type) for k in keys(d)])
end
function fmap(f, d::AbstractDict, type=Union{})
    dict([k => fmap(f, d[k], type) for k in keys(d)])
end
function fmap(f, a::Container, type=Union{})
    isa(a, type) && return f(a)
    fmap.((f,), a, (type,))
end
function fmap(f, x::T, type=Union{}) where {T}
    if isa(x, Number) || isempty(propertynames(x)) || T <: type
        return f(x)
    end
    xs, re = functor(x)
    # re(fmap.((f,), xs, (types,)))
    re(fmap.((f,), xs))
end
kmap(f, x::Map) = fmap(f, x, Any)
leaves(x) = [x]
function leaves(d::Union{Map,AbstractVector{<:AbstractArray}})
    reduce(vcat, leaves.(values(d)))
end

flatten(x::Union{Number,String,Symbol}) = [x]
function flatten(c)
    reduce(vcat, flatten.(values(c)))
end


a = propertynames(1im)