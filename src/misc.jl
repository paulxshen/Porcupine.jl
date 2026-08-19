Base.Any(x) = x
Base.vec(x) = x
Base.length(x) = 1
Base.sort(x) = sort(collect(x))
pairs(x) = [k => x[k] for k in keys(x)]
° = π / 180
Base.isfinite(x) = all(isfinite, x)
Base.isfinite(d::AbstractDict) = all(isfinite, values(d))

Base.getindex(x::Number, k::Str) = x
gaussian(x) = exp(-x^2 / 2)
Base.reverse(x::Number; kw...) = x

function timepassed()
    ignore_derivatives() do
        t = time()
        if haskey(ENV, "time")
            t0 = parse(Float64, ENV["time"])
        else
            t0 = t
        end
        ENV["time"] = t
        t - t0
    end
end


BREAK = "----------------------------------------"
DBREAK = "========================================"
𝒻(x::Integer) = format(x; commas=true)
function 𝒻(x::Number)
    n=round(Int, x)
    d=abs(x-n)
    d==0 && return 𝒻(n)
    n==0 && return round(x, digits=3)
    round(x, digits=2)
end

𝒻(a::AbstractArray) = join(𝒻.(a), ", ")
function 𝒻(d::Map)
    s = JSON.json(d, 4)
    replace(s, "{" => "", "}\n" => "")
end
𝒻(x) = x

call(f, args...) = f(args...)

Base.zero(::Type{Any}) = 0f0
LinearAlgebra.dot(a::AbstractArray, b::Number) = sum(a) * b