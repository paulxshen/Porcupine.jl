Base.Any(x) = x
Base.vec(x) = x
Base.length(x) = 1
Base.sort(x) = sort(collect(x))
pairs(x) = [k => x[k] for k in keys(x)]
° = π / 180

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

function int(x::Real, tol=0.02)
    i = round(Int, x)

    d = abs(x - i)

    @assert d < tol || d / abs(x) < tol "$x"
    i
end
int(x) = fmap(int, x)

# Base.convert(T, x) = convert.(T, x)

# Base.Float64(x::List) = f64(x)
trim(x, dx) = round.(x / dx) * dx
using ChainRulesCore
macro nograd(ex)
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

function gc(ratio=4.0; show=false)
    ignore_derivatives() do
        t = time()
        if !haskey(ENV, "gc")
            ENV["gc"] = "0,0,0,0"
        end
        # for (k, full) = zip(("gctimefull", "gctime"), (true, false))
        Tf, T, df, d = parse.(Float64, split(ENV["gc"], ","))
        if t > Tf
            GC.gc(true)
            t0 = t
            t = time()
            # show && println("""GC took $(t - t0) seconds""")
            df = (t - t0) * ratio
            Tf = t + df
            T = t + d
        elseif t > T
            GC.gc(false)
            t0 = t
            t = time()
            d = (t - t0) * ratio
            T = t + d
            Tf = max(Tf, T)
        else
            return
        end
        ENV["gc"] = "$(Tf),$(T),$(df),$(d)"
    end
end

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

AUTODIFF() = !haskey(ENV, "autodiff") || ENV["autodiff"] == "1"