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

getproperty(x::Map, k::Symbol) = x(k)
function getproperty(m::T, k::Symbol) where T
    hasfield(T, k) && return getfield(m, k)
    fieldcount(T) == 0 && return null
    for f = fieldnames(T)
        v = getproperty(getfield(m, f), k)
        v != null && return v
    end
    null
end
macro getr(ex)
    quote
        Base.getproperty(m::$(esc(ex)), k::Symbol) = getproperty(m, k)
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