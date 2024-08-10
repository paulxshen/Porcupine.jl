Base.map(f::Function, s::AbstractSet) = [f(x) for x = s]

function keys(d)
    ignore_derivatives() do
        collect(Base.keys(d))
    end
end

values(x::NamedTuple) = collect(x)
values(x::Base.RefValue) = x[]
values(d::AbstractDict) = [d[k] for k = keys(d)]
values(x) = Base.values(x)

leaves(x) = [x]
function leaves(d::Dictlike)
    # dict([k => leaves(d[k]) for k in keys(d)])
    reduce(vcat, leaves.(values(d)))
end
function approx_getindex(d, k)
    for _k in keys(d)
        if k ≈ _k
            return d[_k]
        end
    end
    error("Key not found even approximately")
end


Base.haskey(a::NamedTuple, k::String) = false

struct Null end
null = Null()

recursive_getindex(d, k) = null
function recursive_getindex(d::Dictlike, k)
    haskey(d, k) && return d[k]
    for v = values(d)
        v = recursive_getindex(v, k)
        if v != null
            return v
        end
    end
    null
end

function _getindex(d, k)
    if haskey(d, k)
        return d[k]
    end
end

Base.getproperty(d::AbstractDict, k::Symbol) = hasproperty(d, k) ? getfield(d, k) : getindex(d, k)

function (d::Dictlike)(k::Int)
    haskey(d, k) && return d[k]

    if k > 0
        return values(d)[k]
    end
end

function (d::Dictlike)(k::Symbol)
    r = recursive_getindex(d, k)
    r != null && return r
    recursive_getindex(d, string(k))
end

function (d::Dictlike)(k::String)
    r = recursive_getindex(d, k)
    r != null && return r
    recursive_getindex(d, Symbol(k))
end


function dict(v)
    r = OrderedDict()
    for (k, v) = v
        r[k] = v
    end
    r
end


function dict(v::NamedTuple)
    # dict(pairs(v))
    v
end

Ops = Union{typeof.((+, -, *, /))...}
Base.broadcastable(x::AbstractDict) = values(x)
Base.broadcastable(x::SortedDict) = values(x)
Base.broadcastable(x::OrderedDict) = values(x)
Base.broadcastable(x::NamedTuple) = collect(x)

_f(f, x::Dictlike, y,) = dict(broadcast(keys(x), values(y)) do k, v
    k => begin
        if isa(x[k], Dictlike)
            f(x[k], v)
        else
            f.(x[k], v)
        end
    end
end)
Base.:+(x::Dictlike, y) = _f(+, x, y)
function Base.:+(x::Dictlike, y::Dictlike)
    if isempty(x)
        return y
    end
    _f(+, x, y)
end
Base.:+(x, y::Dictlike) = y + x

Base.:-(x::Dictlike,) = _f(*, x, -1)
Base.:-(x::Dictlike, y) = _f(-, x, y)
Base.:-(x::Dictlike, y::Dictlike) = _f(-, x, y)
Base.:-(x, y::Dictlike) = _f((x, y) -> y - x, y, x) #- (y - x)

Base.:*(x::Dictlike, y) = _f(*, x, y)
Base.:*(x::Dictlike, y::Dictlike) = _f(*, x, y)
Base.:*(x, y::Dictlike) = y * x

Base.:/(x::Dictlike, y) = _f(/, x, y)
Base.:/(x::Dictlike, y::Dictlike) = _f(/, x, y)
Base.:/(x, y::Dictlike) = _f((x, y) -> y / x, y, x)

# ZeroTangent
Base.:+(x::ZeroTangent, y::Dictlike) = y
Base.:+(x::Dictlike, y::ZeroTangent) = x

fmap(f, x::Number) = f(x)
fmap(f, x::AbstractArray{<:Number}) = f(x)
fmap(f, x::AbstractArray) = fmap.((f,), x)
function fmap(f, d::Dictlike)
    dict([k => fmap(f, d[k]) for k in keys(d)])
end

# function fmap(f, x::T, types=[]) where {T}
function fmap(f, x::T) where {T}
    # if isempty(propertynames(x)) || T in types
    if isempty(propertynames(x))
        return f(x)
    end
    xs, re = functor(x)
    # re(fmap.((f,), xs, (types,)))
    re(fmap.((f,), xs))
end

function apply(f::Function, d::Dictlike)
    fmap(f, d)
end