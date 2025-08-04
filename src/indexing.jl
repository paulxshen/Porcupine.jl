nn(I::AbstractVector{<:Integer}) = [(I, 1)]
nn(I::NTuple{N,<:Integer}) where {N} = [(I, 1)]
function nn(i; approx=false)
    p = @ignore_derivatives floor.(Int, i)
    q = @ignore_derivatives ceil.(Int, i)

    if approx
        all(p .== q) && return [(p, 1)]
        a = norm(i - p)
        b = norm(i - q)
        return [(p, b / (a + b)), (q, a / (a + b))]
    end
    [(j, prod(1 - abs.(i - j))) for j = @ignore_derivatives Base.product(unique.(zip(p, q))...)]
end
function nn(i::Number; kw...)
    map(nn((i,); kw...)) do (s, w)
        s[1], w
    end
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
AD() = haskey(ENV, "AD") && ENV["AD"] == "1"

function getindexf(a, I::Tuple)
    getindexf(a, I...)
end
isnum(::Number) = true
isnum(a...) = false
function getindexf(a::AbstractArray{T,N}, I...) where {T,N}
    I = map(enumerate(I)) do (i, v)
        v === (:) ? (1:size(a, i)) : v
    end
    s = T.(first.(I))
    l = length.(I)
    p = @ignore_derivatives max.(floor.(Int, s), 1)
    q = @ignore_derivatives min.(ceil.(Int, s), size(a))
    a = a[(:).(p, q + l - 1)...]
    for (d, (s, p, q, l)) = enumerate(zip(s, p, q, l))
        if q > p
            h = d .== 1:N
            a = (q - s) * a[ifelse.(h, (1:l,), (:,))...] + (s - p) * a[ifelse.(h, (2:l+1,), (:,))...]
            # a = (q - s) * selectdim(a, d, 1:l) + (s - p) * selectdim(a, d, 2:l+1)
        end
    end
    all(isnum, I) && return sum(a)
    dims = Tuple(findall(isnum, I))
    !isempty(dims) && return dropdims(a; dims)
    a
    # if q > p
    #     a = (q - s) * selectdim(a, dims - o, int(r + p - s)) + (s - p) * selectdim(a, dims - o, int(r + q - s))
    # elseif isa(r, Real)
    #     a = dropdims(a; dims)
    # end
    # o += isa(r, Real)
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