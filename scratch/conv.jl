using Zygote, ChainRulesCore

# NamedTuple(x) = NamedTuple(x)

function ChainRulesCore.rrule(::typeof(Pair), a::Symbol, b)
    y = Pair(a, b)
    function Pair_pullback(ȳ)
        NoTangent(), adfilter(ȳ[1]), adfilter(ȳ[2])
    end
    return y, Pair_pullback
end

gradient(ones(2, 3)) do a
    diff(a, dims=1)[1]
end