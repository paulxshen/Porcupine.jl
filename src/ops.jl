Scalar = Union{Number,Nothing}
List = Union{AbstractVector,AbstractSet,Tuple}
Container = Union{List,AbstractArray}
Map = Union{AbstractDict,NamedTuple}
Collection = Union{Container,Map}
Text = Union{String,Symbol,AbstractChar}
Index = Union{S,Colon,UnitRange{T}} where {S<:Integer,T<:Integer}

function Base.:+(x, y)
    x == 0 && return y
    y == 0 && return x
    x .+ y
end
function Base.:-(x, y)
    y == 0 && return x
    x .- y
end
function Base.:*(x, y)
    x == 0 || y == 0 && return 0
    x == 1 && return y
    y == 1 && return x
    x .* y
end
function Base.:/(x, y)
    y == 1 && return x
    x ./ y
end

⊙(x::Scalar, y::Scalar) = x * y
function ⊙(x, y)
    x == 0 || y == 0 && return 0
    x == 1 && return y
    y == 1 && return x
    x .⊙ y
end
⊘(x::Scalar, y::Scalar) = x / y
function ⊘(x, y)
    y == 1 && return x
    x .⊘ y
end

# for op in ( :*, :/, :%)
#     @eval Base.$op(x, y) = $(op).(x, y)
# end


Base.:!(x) = Base.:!.(x)
Base.:-(x) = 0 - x

