
function nn(i)
    p = ignore_derivatives() do
        floor.(Int, i)
    end
    q = ignore_derivatives() do
        ceil.(Int, i)
    end
    # p == q && return ([p], [1])

    [(j, prod(1 - abs.(i - j))) for j = @ignore_derivatives Base.product(unique.(zip(p, q))...)]
end

_size(::Scalar) = 1
_size(a) = size(a)
_I(s, v::Scalar) = s
_I(s, v) = range.(s, s .+ size(v) .- 1)
function place!(a, v, start)
    startws = nn(start)
    I = _I(start, v)
    for (s, w) = startws
        a[int.(s - start .+ I)...] += w * v
    end
    a
end

function getindexf(a, I::Tuple)
    getindexf(a, I...)
end

function getindexf(a, I...)
    start = first.(I)
    startws = nn(start)

    sum(startws) do (s, w)
        w * a[int.(s - start .+ I)...]
    end
end


function indexof(v, x::Real)
    v[1] > v[end] && return -indexof(reverse(v), x)

    i = searchsortedfirst(v, x)
    i == 1 && return 1
    i == lastindex(v) + 1 && return lastindex(v)

    a = v[i-1]
    b = v[i]
    i - (b - x) / (b - a)
end