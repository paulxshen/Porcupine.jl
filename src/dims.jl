# Base.ndims(a) = length(size(a))
Base.ndims(::Tuple) = 1
Base.size(x) = (length(x),)
function invperm(v,)
    p = similar(v)
    for i = eachindex(v)
        p[abs(v[i])] = i * sign(v[i])
    end
    p
end

permutedims(a::Number, args...) = a
function permutedims(a, p, N=length(p))
    n = ndims(a)
    np = length(p)
    dims = @ignore_derivatives n < np ? Tuple(n+1:np) : ()

    if !isempty(dims)
        a = adddims(a; dims)
    end
    a = Base.permutedims(a, abs.(p))
    for i = eachindex(p)
        if p[i] < 0
            a = reverse(a, dims=i)
        end
    end
    reshape(a, size(a)[1:N])
end