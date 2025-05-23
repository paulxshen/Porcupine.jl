macro nograd(ex)
    quote
        $(esc(ex)) = ignore_derivatives() do
            $(esc(ex))
        end
    end
end

function cdiff(a; dims=1)
    n = size(a, dims)
    (selectdim(a, dims, 3:n) - selectdim(a, dims, 1:n-2)) / 2
end
Base.diff(x::Number, args...; kw...) = 0
cdiff(x::Number, args...; kw...) = 0
Base.diff(a, i) = diff(a, dims=i)
cdiff(a, i) = cdiff(a; dims=i)

function diffpad(a::AbstractArray{T,N}, v, dims=1; diff=diff) where {T,N}
    # @assert all(!isnan, a)
    vl, vr = v
    s = 1:N .== dims
    l = !isnothing(vl)
    r = !isnothing(vr)
    diff(pad(a, vl, vr, l * s, r * s); dims)
end

struct Del
    diff
    deltas
    padvals
    function Del(deltas=1, padvals=nothing; diff=diff)
        new(diff, deltas, padvals)
    end
end

function LinearAlgebra.cross(m::Del, as::Map)
    @unpack diff, deltas, padvals = m
    ks = keys(as)
    N = ndims(as(1))
    Δs = map(1:N) do i
        getindex.(deltas.(ks), i)
    end
    pads = map(1:N) do i
        getindex.(padvals.(ks), i, :)
    end
    as = values(as)
    delcross(diff, Δs, pads, as)
end

function LinearAlgebra.cross(m::Del, v)
    @unpack diff, deltas, padvals = m
    Δs = values.(deltas)
    pads = values.(padvals)
    delcross(diff, Δs, pads, v)
end

function delcross(diff, Δs, pads, as)
    # diffpad(a, p, dims) = diffpad(a, p...; dims, diff)
    N = ndims(as(1))
    if N == 2
        dx, dy = Δs.(1:2)
        px, py = pads.(1:2)
        if length(as) == 1
            u, = as
            return [diffpad(u, py(1), 2) ./ dy(1), -diffpad(u, px(1), 1) ./ dx(1)]
        elseif length(as) == 2
            u, v = as
            return [diffpad(v, px(2), 1) ./ dx(2) - diffpad(u, py(1), 2) ./ dy(1)]
        else
            error()
        end
    elseif N == 3
        dx, dy, dz = Δs.(1:3)
        px, py, pz = pads.(1:3)
        u, v, w = as
        uy = diffpad(u, py(1), 2) ./ dy(1)
        uz = diffpad(u, pz(1), 3) ./ dz(1)
        vx = diffpad(v, px(2), 1) ./ dx(2)
        vz = diffpad(v, pz(2), 3) ./ dz(2)
        wx = diffpad(w, px(3), 1) ./ dx(3)
        wy = diffpad(w, py(3), 2) ./ dy(3)
        return [wy - vz, uz - wx, vx - uy]
    end
    error()
end
