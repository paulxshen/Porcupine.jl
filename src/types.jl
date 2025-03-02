Scalar = Union{Number,Nothing}
List = Union{AbstractVector,AbstractSet,Tuple}
Container = Union{List,AbstractArray}
Map = Union{AbstractDict,NamedTuple}
Collection = Union{Container,Map}
Text = Union{String,Symbol,AbstractChar}
Index = Union{S,Colon,UnitRange{T}} where {S<:Integer,T<:Integer}
Func = Union{Function,Type}