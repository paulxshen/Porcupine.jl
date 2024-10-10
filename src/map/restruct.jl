fmap(f, x::Number) = f(x)
fmap(f, x::AbstractArray{<:Number}) = f(x)
fmap(f, x::AbstractArray) = fmap.((f,), x)
function fmap(f, d::Map)
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

leaves(x) = [x]
function leaves(d::Union{Map,AbstractVector{<:AbstractArray}})
    reduce(vcat, leaves.(values(d)))
end

flatten(x::Union{Number,String,Symbol}) = [x]
function flatten(c)
    reduce(vcat, flatten.(values(c)))
end


