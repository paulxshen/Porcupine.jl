

Map = Union{AbstractDict,NamedTuple}
List = Union{AbstractArray,AbstractSet,Tuple}
Collection = Union{List,Map}
Numeric = Union{List,Number}
Str = Union{String,Symbol,AbstractChar}
All = Union{Collection,Number,Str}

# LinearAlgebra.dot(x::Numeric, y::Numeric) = sum(x .* y)
Base.:+(x, y) = x .+ y
Base.:-(x, y) = x .- y
Base.:*(x, y) = x .* y
Base.:/(x, y) = x ./ y
# Base.:÷(x, y) = x .÷ y
Base.:%(x, y) = x .% y

Base.:-(x) = 0 - x

Zero = Union{ZeroTangent,Nothing}

Base.:+(x::Map, y::Zero) = x
Base.:+(x::Zero, y::Map) = y
Base.:+(x, y::Zero) = x
Base.:+(x::Zero, y) = y
Base.:+(x::S, y::T) where {S<:Zero,T<:Zero} = S()

Base.:-(x, y::Zero) = x
Base.:-(x::Zero, y) = -y
Base.:-(x::S, y::T) where {S<:Zero,T<:Zero} = S()

Base.:*(x, y::T) where {T<:Zero} = T()
Base.:*(x::T, y) where {T<:Zero} = T()
Base.:*(x::S, y::T) where {S<:Zero,T<:Zero} = S()
