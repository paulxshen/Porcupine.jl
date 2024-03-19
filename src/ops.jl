using DataStructures, ChainRulesCore

° = π / 180
# Base.map(f, c::AbstractSet) = f.(c)
Base.round(x::AbstractFloat) = Base.round(Int, x)
Base.ndims(a) = length(size(a))
Base.size(x) = (length(x),)

Base.getindex(s::Symbol, i) = Symbol(String(s)[i])
# (f::Any)(a...; kw...) = f.(a...; kw...)
# (f::typeof(+))(x::Int)=1

Numberlike = Union{Tuple,AbstractArray,Number}
Base.:-(x::Numberlike, y::Numberlike) = x .- y
Base.:+(x::Numberlike, y::Numberlike) = x .+ y
Base.:*(x::Number, y::Numberlike) = x .* y
Base.:*(x::Numberlike, y::Number) = x .* y
Base.:/(x::Number, y::Numberlike) = x ./ y
Base.:/(x::Numberlike, y::Number) = x ./ y

function keys(x)
    ignore_derivatives() do
        Base.keys(x) |> collect
    end
end

function values(x::AbstractDict)
    [x[k] for k = keys(x)]
end
values(x::NamedTuple) = collect(x)
values(x) = Base.values(x)

# function dict(T::Type{NamedTuple}, v)
#     NamedTuple(v)
# end

# function dict(T::Type{AbstractDict}, v)
function dict(T, v)
    if T <: NamedTuple
        return NamedTuple(v)
    end
    r = T()
    for (k, v) = v
        r[k] = v
    end
    r
end

function dict(v)
    dict(OrderedDict{Symbol,Any}, v)
end

Dictlike = Union{AbstractDict,NamedTuple}
Ops = Union{typeof.((+, -, *, /))...}
# dmul(a, b) = [a .* b for (a, b) = zip(values(a), values(b))]
# Base.broadcast(f, d::Dictlike) = [f(d[k]) for k = keys(d)]
# Base.map(f, d::Dictlike) = [f(d[k]) for k = keys(d)]
Base.broadcastable(x::AbstractDict) = values(x)

_f(T, f, x, y::Number, r=false) = dict(T, [k => r ? f.(y, x[k]) : f.(x[k], y) for k = keys(x)])
_f(T, f, x, y, r=false) = dict(T, [k => r ? f.(y, x[k]) : f.(x[k], y) for (k, y) = zip(keys(x), values(y))])

# (f::Ops)(x::T, y) where {T<:Dictlike} = _f(T, f, x, y)
# (f::Ops)(x::T, y::T) where {T<:Dictlike} = _f(T, f, x, y)
# (f::Ops)(x, y::T) where {T<:Dictlike} = f(y, x)

Base.:+(x::T, y) where {T<:Dictlike} = _f(T, +, x, y)
Base.:+(x::T, y::T) where {T<:Dictlike} = _f(T, +, x, y)
Base.:+(x, y::T) where {T<:Dictlike} = y + x

Base.:-(x::T,) where {T<:Dictlike} = _f(T, *, x, -1)
Base.:-(x::T, y) where {T<:Dictlike} = _f(T, -, x, y)
Base.:-(x::T, y::T) where {T<:Dictlike} = _f(T, -, x, y)
Base.:-(x, y::T) where {T<:Dictlike} = _f(T, -, y, x, true) #- (y - x)

Base.:*(x::T, y) where {T<:Dictlike} = _f(T, *, x, y)
Base.:*(x::T, y::T) where {T<:Dictlike} = _f(T, *, x, y)
Base.:*(x, y::T) where {T<:Dictlike} = y * x

Base.:/(x::T, y) where {T<:Dictlike} = _f(T, /, x, y)
Base.:/(x::T, y::T) where {T<:Dictlike} = _f(T, /, x, y)
Base.:/(x, y::T) where {T<:Dictlike} = _f(T, /, y, x, true)

# Base.:-(x::T, y) where T<:Dictlike = dict(T,[k => (x[k] - y) for (k, y) = zip(keys(x), (y))])
# Base.:*(a::T, b) where {T<:Dictlike} = dict(T, [a[k] .* b for (k, b) = zip(keys(a), values(b))])
# Base.:*(a::T, b::T) where {T<:Dictlike} = dict(T, [a[k] .* b for (k, b) = zip(keys(a), b |> values)])
# Base.:*(a, b::T) where {T<:Dictlike} = b * a
# Base.:*(a::T, b) where {T<:Dictlike} = dict(T, [a[k] .* b for (k, b) = zip(keys(a), values(b))])
# Base.:*(a::T, b::T) where {T<:Dictlike} = dict(T, [a[k] .* b for (k, b) = zip(keys(a), b |> values)])
# Base.:*(a, b::T) where {T<:Dictlike} = b * a





# Base.:*(a::VF, b::AbstractArray{<:Number}) = a * [b]
# Base.:*(a::AbstractArray{<:Number}, b::VF) = [a] * b
# Base.:/(a::VF, b::VF) =
#     broadcast(values(a), values(b)) do a, b
#         a ./ b
#     end
# Base.:/(a::VF, b::AbstractArray{<:Number}) = a / [b]
# Base.:/(a::AbstractArray{<:Number}, b::VF) = [a] / b

(m::Number)(a...) = m
d2(x) = round.(x, sigdigits=2)
gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)

