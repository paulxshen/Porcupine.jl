

Dictlike = Union{AbstractDict,NamedTuple}
List = Union{AbstractArray,AbstractSet,Tuple}
Collection = Union{List,Dictlike}
Numeric = Union{List,Number}
Str = Union{String,Symbol}
All = Union{Collection,Number,Str}

# LinearAlgebra.dot(x::Numeric, y::Numeric) = sum(x .* y)
Base.:+(x, y) = x .+ y
Base.:-(x, y) = x .- y
Base.:*(x, y) = x .* y
Base.:/(x, y) = x ./ y

Base.:-(x) = 0 - x
Base.:+(x::All, y::Nothing) = x
Base.:+(x::Nothing, y::All) = y
Base.:+(x::Dictlike, y::Nothing) = x
Base.:+(x::Nothing, y::Nothing) = nothing
Base.:*(x, y::Nothing) = nothing
Base.:*(x::Nothing, y) = nothing
Base.:*(x::Nothing, y::Nothing) = nothing
