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




struct Del
    diff
    deltas
    lpads
    upads
    function Del(deltas=1, lpads=nothing, upads=nothing, diff=diff)
        new(diff, deltas, lpads, upads)
    end
end

function LinearAlgebra.cross(m::Del, v)
    @unpack diff, deltas, lpads, upads = m
    delcross(diff, deltas, lpads, upads, _values(v))
end

function delcross(diff, deltas, lpads, upads, as)
    @nograd deltas, lpads, upads
    N = ndims(as[1])
    if N == 2
        if length(as) == 1
            u, = as
            return [diffpad(u, lpads(2)(1), upads(2)(1), 2) ./ deltas(2)(1), -diffpad(u, lpads(1)(1), upads(1)(1), 1) ./ deltas(1)(1)]
        elseif length(as) == 2
            u, v = as
            return [diffpad(v, lpads(1)(2), upads(1)(2), 1) ./ deltas(1)(2) - diffpad(u, lpads(2)(1), upads(2)(1), 2) ./ deltas(2)(1)]
        else
            error()
        end
    elseif N == 3
        u, v, w = as
        uy = diffpad(u, lpads(2)(1), upads(2)(1), 2) ./ deltas(2)(1)
        uz = diffpad(u, lpads(3)(1), upads(3)(1), 3) ./ deltas(3)(1)
        vx = diffpad(v, lpads(1)(2), upads(1)(2), 1) ./ deltas(1)(2)
        vz = diffpad(v, lpads(3)(2), upads(3)(2), 3) ./ deltas(3)(2)
        wx = diffpad(w, lpads(1)(3), upads(1)(3), 1) ./ deltas(1)(3)
        wy = diffpad(w, lpads(2)(3), upads(2)(3), 2) ./ deltas(2)(3)
        return [wy - vz, uz - wx, vx - uy]
    end
    error()
end
