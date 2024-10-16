Base.Any(x) = x

# ° = π / 180
# (m::Number)(a...) = m
# d2(x) = round.(x, sigdigits=2)
# gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)

round(x) = Base.round.(Int, x)
round(T, x) = Base.round.(T, x)
floor(x) = Base.floor.(Int, x)
floor(T, x) = Base.floor.(T, x)
ceil(x) = Base.ceil.(Int, x)
ceil(T, x) = Base.ceil.(T, x)

Base.ndims(a) = length(size(a))
Base.size(x) = (length(x),)
# Base.length(x) = 1

# Base.convert(T, x) = convert.(T, x)

# Base.Float64(x::List) = f64(x)
trim(x, dx) = round.(x / dx) * dx

° = π / 180
gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)

# Base.reduce(f, xs, init, args...; dims=1, kw...) = Base.reduce(f, xs; init, dims)