Base.haskey(a::NamedTuple, k::String) = false

struct Null end
null = Null()

function approx_getindex(d, k)
    for _k in keys(d)
        if k ≈ _k
            return d[_k]
        end
    end
    error("Key not found even approximately")
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

function _getindex(d, k)
    if haskey(d, k)
        return d[k]
    end
end

Base.getproperty(d::AbstractDict, k::Symbol) = hasproperty(d, k) ? getfield(d, k) : d(k)

function (d::Map)(k::Int)
    haskey(d, k) && return d[k]
    if k > 0
        return values(d)[k]
    end
end

function (d::Map)(k::Symbol)
    r = recursive_getindex(d, k)
    r != null && return r
    recursive_getindex(d, string(k))
end

function (d::Map)(k::String)
    r = recursive_getindex(d, k)
    r != null && return r
    recursive_getindex(d, Symbol(k))
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
