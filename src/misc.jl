Base.Any(x) = x
Base.vec(x) = x
Base.length(x) = 1
Base.sort(x) = sort(collect(x))
pairs(x) = [k => x[k] for k in keys(x)]
° = π / 180
(m::Number)(a...) = m
Base.getindex(x::Number, k::Text) = x
gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)
dropitr(x) = first(x) == last(x) ? first(x) : x
function adddims(a; dims)
    sz = ignore_derivatives() do
        sz = ones(Int, length(dims) + ndims(a))
        dims0 = collect(size(a))
        for i = 1:length(sz)
            if i in dims
            else
                sz[i] = popfirst!(dims0)
            end
        end
        sz
    end
    reshape(a, Tuple(sz))
end

round(x) = Base.round.(Int, x)
round(T, x) = Base.round.(T, x)
floor(x) = Base.floor.(Int, x)
floor(T, x) = Base.floor.(T, x)
ceil(x) = Base.ceil.(Int, x)
ceil(T, x) = Base.ceil.(T, x)

function int(x::Real)
    i = round(Int, x)
    @assert abs(x - i) < 5e-2 "$x"
    i
end
int(x) = fmap(int, x)

# Base.convert(T, x) = convert.(T, x)

# Base.Float64(x::List) = f64(x)
trim(x, dx) = round.(x / dx) * dx
using ChainRulesCore
macro ignore_derivatives_vars(ex)
    quote
        $(esc(ex)) = ignore_derivatives() do
            $(esc(ex))
        end
    end
end

macro convert(T, ex)
    quote
        $(esc(ex)) = fmap($(esc(ex))) do x
            convert.($(esc(T)), x)
        end
    end
end
