Base.haskey(a::NamedTuple, k::String) = false

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


recursive_getindex(d, k) = null
function recursive_getindex(d::Map, k)
    haskey(d, k) && return d[k]
    for v = values(d)
        v = recursive_getindex(v, k)
        if v != null
            return v
        end
    end
    null
end

function Base.getproperty(d::AbstractDict, k::Symbol)
    if hasproperty(d, k)
        @warn "returning $(typeof(d)) property $k not key $k"
        getfield(d, k)
    end
    d(k)
end

function (d::Map)(k::Int)
    haskey(d, k) && return d[k]
    if k > 0
        return values(d)[k]
    end
end

_alt(x::Symbol) = string(x)
_alt(x::String) = Symbol(x)
function (d::Map)(k::Text)
    r = recursive_getindex(d, k)
    r != null && return r
    r = recursive_getindex(d, _alt(k))
    r != null && return r
    error("$k not found, even recursively")
end

function (d::Map)(k::Real)
    r = recursive_getindex(d, k)
    r != null && return r
    r = recursive_getindex(d, Symbol(k))
    r != null && return r
    r = recursive_getindex(d, string(k))
    r != null && return r
    r = approx_getindex(d, k)
    r != null && return r
    error("$k not found, even recursively or approximately")
end



function (d::Map)(rx::Regex)
    ks = ignore_derivatives() do
        filter(keys(d)) do k
            match(rx, string(k)) != nothing
        end
    end
    # println(ks)
    namedtuple([k => d[k] for k in ks])
end
