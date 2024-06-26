Base.map(f::Function, s::AbstractSet) = [f(x) for x = s]

function keys(d)
    ignore_derivatives() do
        collect(Base.keys(d))
    end
end
# keys(x) = [k for k in Base.keys(x)]
# function values(x::AbstractDict)
#     [x[k] for k = keys(x)]
# end
values(x::NamedTuple) = collect(x)
values(x::Base.RefValue) = x[]
values(d::AbstractDict) = [d[k] for k = keys(d)]
values(x) = Base.values(x)

# Base.values(x::AbstractDict) = values(x)

Base.getindex(d::NamedTuple, i::CartesianIndex) = values(d)[i]

function flatten(d::Dictlike)
    merge([isa(v, Dictlike) ? flatten(v) : dict([k => v]) for (k, v) in pairs(d)]...)
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
function recursive_getindex(c, k)
    if k in keys(c)
        return c[k]
    elseif isa(c, Dictlike)
        for v = values(c)
            v = recursive_getindex(v, k)
            if v != null
                return v
            end
        end
    end
    null
end

function _getindex(d, k)
    if haskey(d, k)
        return d[k]
    end
    if haskey(d, string(k))
        return d[string(k)]
    end
    if haskey(d, Symbol(k))
        return d[Symbol(k)]
    end

    if isa(k, Integer) && k > 0
        return values(d)[k]
    end

    r = recursive_getindex(d, k)
    if r != null
        return r
    end
    r = recursive_getindex(d, string(k))
    if r != null
        return r
    end
end

Base.getproperty(d::AbstractDict, k::Symbol) = hasproperty(d, k) ? getfield(d, k) : _getindex(d, k)
(d::Dictlike)(k) = _getindex(d, k)
# Base.getproperty(a::AbstractArray, k::Symbol) = hasproperty(a, k) ? getfield(a, k) : getproperty.(a, k)
# (haskey(d, k) ? d[k] : d[string(k)])
Base.getindex(c::Dictlike, k, opt::Union{Symbol,String}) =
    if opt == :r
        recursive_getindex(c, k)
    else
        c[k]
    end

function dict(v)
    r = OrderedDict()
    for (k, v) = v
        r[k] = v
    end
    r
end


function dict(v::NamedTuple)
    dict(pairs(v))
end

Ops = Union{typeof.((+, -, *, /))...}
Base.broadcastable(x::AbstractDict) = values(x)
Base.broadcastable(x::SortedDict) = values(x)
Base.broadcastable(x::OrderedDict) = values(x)
Base.broadcastable(x::NamedTuple) = collect(x)

_f(f, x::Dictlike, y,) = dict(broadcast(keys(x), values(y)) do k, v
    global aa = x
    global bb = y
    k => begin
        if isa(x[k], Dictlike)
            f(x[k], v)
        else
            f.(x[k], v)
        end
    end
end)
# _f(f, x::Dictlike, y,) = dict(Pair.(keys(x), ((a, b) -> isa(a, Dictlike) ? f(a, b) : f.(a, b)).(values(x), values(y))))
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

function apply(f::Function, d::Dictlike)
    dict([k => isa(d[k], Dictlike) ? apply(f, d[k]) : f(d[k]) for k in keys(d)])

end