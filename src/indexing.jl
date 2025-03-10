nn(I::AbstractVector{<:Integer}) = [(I, 1)]
nn(I::NTuple{N,<:Integer}) where {N} = [(I, 1)]
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
function place!(a, v, start; additive=true)
    startws = nn(start)
    I = _I(start, v)
    for (s, w) = startws
        I1 = int.(s - start + I)
        if !additive
            a[I1...] = w * v
        else
            a[I1...] += w * v
        end
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