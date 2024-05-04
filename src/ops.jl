using DataStructures, ChainRulesCore, LinearAlgebra

# Base.map(f, c::AbstractSet) = f.(c)
# (f::Any)(a...; kw...) = f.(a...; kw...)
# (f::typeof(+))(x::Int)=1

Dictlike = Union{AbstractDict,NamedTuple}
List = Union{AbstractArray,AbstractSet,Tuple}
Collection = Union{List,Dictlike}
Numeric = Union{List,Number}

LinearAlgebra.dot(x::Numeric, y::Numeric) = sum(x .* y)
Base.:-(x::Numeric, y::Numeric) = x .- y
Base.:+(x::Numeric, y::Numeric) = x .+ y
Base.:*(x::Number, y::Numeric) = x .* y
Base.:*(x::Numeric, y::Number) = x .* y
Base.:/(x::Number, y::Numeric) = x ./ y
Base.:/(x::Numeric, y::Number) = x ./ y

function keys(x)
    ignore_derivatives() do
        Base.keys(x) |> collect
    end
end

function values(x)
    [x[k] for k = keys(x)]
end
# Base.values(x::NamedTuple) = collect(x)
# values(x) = Base.values(x)
Base.getproperty(d::AbstractDict, k::Symbol) = hasproperty(d, k) ? getfield(d, k) : (haskey(d, k) ? d[k] : d[string(k)])

# Base.getindex(d::NamedTuple, i::Int) = values(d)[i]
# _getindex(d::AbstractDict, k::Int) = haskey(d, k) ? d[k] : values(d)[k]
# Base.getindex(d::Dict, k::Int) = _getindex(d, k)
# Base.getindex(d::SortedDict, k::Int) = _getindex(d, k)
# Base.getindex(d::OrderedDict, k::Int) = _getindex(d, k)

struct Null end
null = Null()
# function _getindex(c, k)
#     if k in keys(c)
#         return c[k]
#     else
#         for v = values(c)
#             v = _getindex(v, k)
#             if v != null
#                 return v
#             end
#         end
#     end
#     null
# end

# Base.getindex(c::AbstractDict, k::Union{Symbol,String,Number}) = _getindex(c, k)
# Base.getindex(c::NamedTuple, k) = _getindex(c, k)
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

° = π / 180
(m::Number)(a...) = m
d2(x) = round.(x, sigdigits=2)
gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)

Base.round(x::AbstractFloat) = Base.round(Int, x)
Base.round(a) = Base.round.(a)
Base.ndims(a) = length(size(a))
Base.size(x) = (length(x),)

Base.getindex(s::Symbol, i) = Symbol(String(s)[i])

Base.convert(T, x) = convert.(T, x)
Base.Float16(x::List) = Float16.(x)
Base.Float32(x::List) = Float32.(x)
Base.Float64(x::List) = Float64.(x)
