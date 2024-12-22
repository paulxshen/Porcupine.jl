Numeric = Union{Number,AbstractArray{<:Number}}
List = Union{AbstractVector,AbstractSet,Tuple}
Container = Union{List,AbstractArray}
Map = Union{AbstractDict,NamedTuple}
Collection = Union{Container,Map}
Text = Union{String,Symbol,AbstractChar}
Index = Union{S,Colon,UnitRange{T}} where {S<:Integer,T<:Integer}

⊙(x::Numeric, y::Numeric) = x .* y
⊘(x::Numeric, y::Numeric) = x ./ y

for op in (:+, :-, :*, :/, :%)
    @eval Base.$op(x, y) = $(op).(x, y)
end

for op in (:⊙, :⊘)
    @eval $op(x, y) = broadcast($op, x, y)
end

Base.:!(x::Container) = Base.:!.(x)
Base.:-(x) = 0 - x

