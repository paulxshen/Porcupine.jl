

# ° = π / 180
# (m::Number)(a...) = m
# d2(x) = round.(x, sigdigits=2)
# gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)

Base.round(x::AbstractFloat) = Base.round.(Int, x)
Base.floor(x::AbstractFloat) = Base.floor.(Int, x)
Base.ceil(x::AbstractFloat) = Base.ceil.(Int, x)
Base.round(a::List) = Base.round.(a)
Base.floor(a::List) = Base.floor.(a)
Base.ceil(a::List) = Base.ceil.(a)

Base.ndims(a) = length(size(a))
Base.size(x) = (length(x),)
# Base.length(x) = 1

Base.getindex(s::Symbol, i) = Symbol(String(s)[i])
Base.convert(::Type{Symbol}, x::String) = Symbol(x)
Base.convert(::Type{String}, x::Symbol) = string(x)
# Base.convert(T, x) = convert.(T, x)

# Base.Float64(x::List) = f64(x)
whole(x, dx) = round(x / dx) * dx

° = π / 180
gaussian(x; μ=0, σ=1) = exp(-((x - μ) / σ)^2)
