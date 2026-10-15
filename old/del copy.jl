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

function diffpad(a, vl, vr=vl; dims=1, diff=diff, autodiff=true)
    # @assert all(!isnan, a)

    sel = 1:ndims(a) .== dims
    l = !isnothing(vl)
    r = !isnothing(vr)
    # @time b[range.(l * sel + 1, sz - r * sel)...] = diff(a; dims)
    # @time pad!(b, vl, l * sel, 0)
    # @time pad!(b, vr, 0, r * sel)
    # println()

    if autodiff
        vl ∈ (0, nothing) && @nograd vl
        vr ∈ (0, nothing) && @nograd vr
        b = diff(a; dims)
        b = pad(b, vl, vr, l * sel, r * sel)
    else
        sz = Tuple(size(a) + (l + r - 1) * sel)
        b = similar(a, sz)
        b[range.(l * sel + 1, sz - r * sel)...] = diff(a; dims)
        pad!(b, vl, vr, l * sel, r * sel)
        # @time b[range.(l * sel + 1, sz - r * sel)...] = diff(a; dims)
        # @time pad!(b, vl, vr, l * sel, r * sel)
        # println()
    end
    @assert typeof(b) == typeof(a)
    b
    # if autodiff
    #     copy(b)
    # else
    #     b
    # end
    # else
    # a = diff(a; dims)
    # a = pad(a, vl, l * sel, 0)
    # a = pad(a, vr, 0, r * sel)
end

struct Del
    diff
    deltas
    padvals
    function Del(deltas=1, padvals=nothing; diff=diff)
        new(diff, deltas, padvals)
    end
end

function LinearAlgebra.cross(m::Del, d::Map)
    @unpack diff, deltas, padvals = m
    ks = keys(d)
    N = ndims(d(1))
    Δs = map(1:N) do i
        getindex.(deltas.(ks), i)
    end
    ps = map(1:N) do i
        getindex.(padvals.(ks), i, :)
    end
    as = _values(d)
    delcross(diff, Δs, ps, as)
end

function LinearAlgebra.cross(m::Del, v)
    @unpack diff, deltas, padvals = m
    Δs = _values.(deltas)
    ps = _values.(padvals)
    delcross(diff, Δs, ps, v)
end

function delcross(diff, Δs, ps, as)
    autodiff = AUTODIFF()
    @nograd Δs

    _diffpad(a, p, dims) = diffpad(a, p...; dims, diff, autodiff)
    N = ndims(as(1))
    if N == 2
        dx, dy = [Δs(i) for i = 1:2]
        if length(as) == 1
            u, = as
            return [_diffpad(u, ps(2)(1), 2) ./ dy(1), -_diffpad(u, ps(1)(1), 1) ./ dx(1)]
        elseif length(as) == 2
            u, v = as
            return [_diffpad(v, ps(1)(2), 1) ./ dx(2) - _diffpad(u, ps(2)(1), 2) ./ dy(1)]
        else
            error()
        end
    elseif N == 3
        dx, dy, dz = Δs.(1:3)
        u, v, w = as
        uy = _diffpad(u, ps(2)(1), 2) ./ dy(1)
        uz = _diffpad(u, ps(3)(1), 3) ./ dz(1)
        vx = _diffpad(v, ps(1)(2), 1) ./ dx(2)
        vz = _diffpad(v, ps(3)(2), 3) ./ dz(2)
        wx = _diffpad(w, ps(1)(3), 1) ./ dx(3)
        wy = _diffpad(w, ps(2)(3), 2) ./ dy(3)
        return [wy - vz, uz - wx, vx - uy]
    end
    error()
end
