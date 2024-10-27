
function _bmap(f::Function, x, y)
    # if any(isempty, y)
    #     return x
    # end
    Pair.(keys(x), broadcast(f, values(x), values(y)))
    # ks = keys(x)
    # vs = values(y)
    # m = length(ks)
    # n = length(vs)
    # broadcast(1:m, 1:n) do i, j
    #     ks[i] => f(x[ks[i]], vs[j])
    # end
    # broadcast(keys(x), values.(y)...) do k, vs...
    # broadcast(keys(x), values(y)) do k, v
    #     # k => f(x[k], vs...)
    #     k => f(x[k], v)
    # end
end
bmap(f::Function, x::NamedTuple, y) = namedtuple(_bmap(f, x, y))
bmap(f::Function, x::AbstractDict, y) = dict(_bmap(f, x, y))

for op in Symbol.(("+", "*", "-", "/"))
    @eval Base.$op(x::Map, y) = bmap(Base.$op, x, y)
    @eval Base.$op(x::S, y::T) where {S<:Map,T<:Map} = bmap(Base.$op, x, y)
end
for op in (:⊙, :⊘)
    @eval $op(x::Map, y) = bmap($op, x, y)
    @eval $op(x::S, y::T) where {S<:Map,T<:Map} = bmap($op, x, y)
end

for op in (:+, :*)
    @eval Base.$op(x, y::Map) = bmap(Base.$op, y, x)
end
for op in (:⊙,)
    @eval $op(x, y::Map) = bmap($op, y, x)
end

for op in (:-, :/)
    @eval Base.$op(x, y::Map) =
        bmap(y, x) do y, x
            Base.$op(x, y)
        end
end
for op in (:⊘,)
    @eval $op(x, y::Map) =
        bmap(y, x) do y, x
            $op(x, y)
        end
end
