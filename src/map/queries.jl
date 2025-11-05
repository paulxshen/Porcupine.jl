Base.haskey(a::NamedTuple, k::AbstractString) = false

struct Null end
null = Null()

function approx_getindex(d, k)
    for _k in keys(d)
        if k ≈ _k
            return d[_k]
        end
    end
    null
end


getindexr(d, k) = null
function getindexr(d::Map, k)
    haskey(d, k) && return d[k]
    for v = _values(d)
        v = getindexr(v, k)
        if v != null
            return v
        end
    end
    null
end

# function Base.getproperty(d::AbstractDict, k::Symbol)
#     if hasproperty(d, k)
#         # @warn "returning $(typeof(d)) property $k not key $k"
#         return getfield(d, k)
#     end
#     d(k)
# end
# Base.getproperty(d::NamedTuple, k) = d(k)

function (d::Map)(k::Int)
    haskey(d, k) && return d[k]
    _values(d)[k]
end

_alt(x::Symbol) = string(x)
_alt(x::AbstractString) = Symbol(x)
function (d::Map)(k::Str, v=null)
    r = getindexr(d, k)
    r != null && return r
    r = getindexr(d, _alt(k))
    r != null && return r
    v
end

function (d::Map)(k::Real)
    r = getindexr(d, k)
    r != null && return r
    r = getindexr(d, Symbol(k))
    r != null && return r
    r = getindexr(d, string(k))
    r != null && return r
    r = approx_getindex(d, k)
    r != null && return r
    error("$k not found, even recursively or approximately")
end



function _ff(T, d, rx::Regex)
    ks = ignore_derivatives() do
        filter(keys(d)) do k
            match(rx, string(k)) != nothing
        end
    end
    T([k => d[k] for k in ks])
end
(m::NamedTuple)(rx::Regex) = _ff(namedtuple, m, rx)
(m::AbstractDict)(rx::Regex) = _ff(dict, m, rx)
