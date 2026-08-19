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

function fitix(start, stop, sz)
    start1=max.(start, 1)
    stop1=min.(stop, sz)

    start1=start1+stop1-stop
    stop1=stop1+start1-start

    start1, stop1
end

_size(::Scalar) = 1
_size(a) = size(a)
_I(s, v::Scalar) = s
_I(s, v) = range.(s, s .+ size(v) .- 1, size(v))
function place!(a, v, start; additive=true)
    start, = fitix(start, start + _size(v) - 1, size(a))
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

isnum(::Number) = true
isnum(a...) = false

getindexf(a, I::Vararg{Integer,N}) where {N} = a[I...]
function getindexf(a::AbstractArray{T,N}, I::Vararg{Real}) where {T,N}
    I = T.(I)
    p = @ignore_derivatives max.(floor.(Int, I), 1)
    q = @ignore_derivatives min.(ceil.(Int, I), size(a))
    a = a[(:).(p, q)...]
    for (d, (s, p, q)) = enumerate(zip(I, p, q))
        if q > p
            h = d .== 1:N
            a = (q - s) * a[ifelse.(h, (1:1,), (:,))...] + (s - p) * a[ifelse.(h, (2:2,), (:,))...]
        end
    end
    sum(a)
end

function getindexf(a::AbstractArray{T,N}, I...) where {T,N}
    I = map(enumerate(I)) do (i, v)
        v === (:) ? (1:size(a, i)) : v
    end

    f=first.(I)
    start, stop=fitix(f, last.(I), size(a))
    p = @ignore_derivatives floor.(Int, start)
    q = @ignore_derivatives ceil.(Int, start)

    l = length.(I)
    a = a[(:).(p, q+l-1)...]
    for (dims, (f, p, q, l)) = enumerate(zip(f, p, q, l))
        if q > p
            h=dims .== 1:N
            a = (q - f) * a[ifelse.(h, (1:l,), (:,))...] + (f - p) * a[ifelse.(h, (2:(l+1),), (:,))...]
        end
    end
    dims = Tuple(findall(isnum, I))
    !isempty(dims) && return dropdims(a; dims)
    a
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