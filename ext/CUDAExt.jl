module CUDAExt
using CUDA, Porcupine, ChainRulesCore
function ChainRulesCore.rrule(::typeof(cu), a::Array)
    # @show ps
    y = cu(a)
    function pb(ȳ)
        NoTangent(), Array(ȳ)
    end
    return y, pb
end
function ChainRulesCore.rrule(T::Type{CuArray}, a::Array)
    # @show ps
    y = T(a)
    function pb(ȳ)
        NoTangent(), Array(ȳ)
    end
    return y, pb
end
end
