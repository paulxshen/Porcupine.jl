

for op in Symbol.(("+", "*", "-", "/"))
    @eval Base.$op(x::Map, y) = kmap(Base.$op, x, y)
    @eval Base.$op(x::S, y::T) where {S<:Map,T<:Map} = kmap(Base.$op, x, y)
end
for op in (:⊙, :⊘)
    @eval $op(x::Map, y) = kmap($op, x, y)
    @eval $op(x::S, y::T) where {S<:Map,T<:Map} = kmap($op, x, y)
end

for op in (:+, :*)
    @eval Base.$op(x, y::Map) = kmap(Base.$op, y, x)
end
for op in (:⊙,)
    @eval $op(x, y::Map) = kmap($op, y, x)
end

for op in (:-, :/)
    @eval Base.$op(x, y::Map) =
        kmap(y, x) do y, x
            Base.$op(x, y)
        end
end
for op in (:⊘,)
    @eval $op(x, y::Map) =
        kmap(y, x) do y, x
            $op(x, y)
        end
end

-(::Nothing, y::Union{AbstractDict,NamedTuple}) = -y