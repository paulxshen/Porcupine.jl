

for op in Symbol.(("+", "*", "-", "/"))
    @eval Base.$op(x::Map, y) = vmap(Base.$op, x, y)
    @eval Base.$op(x::S, y::T) where {S<:Map,T<:Map} = vmap(Base.$op, x, y)
end
for op in (:⊙, :⊘)
    @eval $op(x::Map, y) = vmap($op, x, y)
    @eval $op(x::S, y::T) where {S<:Map,T<:Map} = vmap($op, x, y)
end

for op in (:+, :*)
    @eval Base.$op(x, y::Map) = vmap(Base.$op, y, x)
end
for op in (:⊙,)
    @eval $op(x, y::Map) = vmap($op, y, x)
end

for op in (:-, :/)
    @eval Base.$op(x, y::Map) =
        vmap(y, x) do y, x
            Base.$op(x, y)
        end
end
for op in (:⊘,)
    @eval $op(x, y::Map) =
        vmap(y, x) do y, x
            $op(x, y)
        end
end

Base.:-(::Nothing, y::Union{AbstractDict,NamedTuple}) = -y