Base.Any(x) = x
Base.vec(x) = x
Base.length(x) = 1
Base.sort(x) = sort(collect(x))
pairs(x) = [k => x[k] for k in keys(x)]
° = π / 180

Base.getindex(x::Number, k::Str) = x
gaussian(x) = exp(-x^2 / 2)
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


Base.reverse(x::Number; kw...) = x

# Base.convert(T, x) = convert.(T, x)

# Base.Float64(x::List) = f64(x)
trim(x, dx) = round.(x / dx) * dx
round1(x) = round(x, digits=1)
round2(x) = round(x, digits=2)
round3(x) = round(x, digits=3)
round4(x) = round(x, digits=4)
round5(x) = round(x, digits=5)
round6(x) = round(x, digits=6)

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

AUTODIFF() = haskey(ENV, "AUTODIFF") && ENV["AUTODIFF"] == "1"


BREAK = "----------------------------------------"
DBREAK = "========================================"
disp(x::Number) = format(x; commas=true, precision=2)
function disp(d::Map)
    s = JSON.json(d, 4)
    replace(s, "{" => "", "}\n" => "")
end
disp(x) = x