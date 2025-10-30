

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

⊙(x::Number, y::Number) = x * y
function ⊙(x, y)
    (x == 0 || y == 0) && return 0
    x == 1 && return y
    y == 1 && return x
    x .⊙ y
end
⊙(x::Map, y::Number) = vmap(v -> v * y, x)

⊘(x::Number, y::Number) = x / y
function ⊘(x, y)
    y == 1 && return x
    x .⊘ y
end
⊘(x::Map, y::Number) = vmap(v -> v / y, x)

# for op in ( :*, :/, :%)
#     @eval Base.$op(x, y) = $(op).(x, y)
# end


Base.:!(x) = Base.:!.(x)
Base.:-(x) = 0 - x

Base.getindex(c::Base.Iterators.Zip, i::Integer) = collect(c)[i]