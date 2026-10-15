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

getindexf(a::AbstractArray, I::Vararg{Integer}) = a[I...]
# multilinear interpolation: outer product of per-dim weights against the surrounding corners
function getindexf(a::AbstractArray{T}, I::Vararg{Real,M}) where {T,M}
    I = T.(I)
    p = @ignore_derivatives max.(floor.(Int, I), 1)
    q = @ignore_derivatives min.(ceil.(Int, I), size(a)[1:M])
    w = ntuple(M) do d
        v = p[d] == q[d] ? [one(T)] : [q[d] - I[d], I[d] - p[d]]
        reshape(v, ntuple(i -> i == d ? length(v) : 1, M))
    end
    sum(.*(w...) .* a[(:).(p, q)...])
end

function getindexf(a::AbstractArray{T,N}, I...) where {T,N}
    I = map(enumerate(I)) do (i, v)
        v === (:) ? (1:size(a, i)) : v
    end

    f = first.(I)
    start, stop = fitix(f, last.(I), size(a))
    p = @ignore_derivatives floor.(Int, start)
    q = @ignore_derivatives ceil.(Int, start)

    l = length.(I)
    a = view(a, (:).(p, q + l - 1)...)
    for (d, (f, p, q, l)) = enumerate(zip(f, p, q, l))
        q > p && (a = _lerp(a, d, l, q - f, f - p))
    end
    a isa SubArray && (a = copy(a))
    dims = Tuple(findall(isnum, I))
    !isempty(dims) && return dropdims(a; dims)
    a
end
_lerp(a, d, l, u, v) = u .* selectdim(a, d, 1:l) .+ v .* selectdim(a, d, 2:(l+1))
# hand-written pullback: ~1.5x faster AD than Zygote's broadcast+view adjoints
function ChainRulesCore.rrule(::typeof(_lerp), a, d, l, u, v)
    x, y = selectdim(a, d, 1:l), selectdim(a, d, 2:(l+1))
    function pb(ȳ)
        ȳ = unthunk(ȳ)
        ā = zero(a)
        selectdim(ā, d, 1:l) .+= u .* ȳ
        selectdim(ā, d, 2:(l+1)) .+= v .* ȳ
        NoTangent(), ā, NoTangent(), NoTangent(), ProjectTo(u)(dot(x, ȳ)), ProjectTo(v)(dot(y, ȳ))
    end
    u .* x .+ v .* y, pb
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