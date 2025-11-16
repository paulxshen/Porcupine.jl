module CUDAExt
using CUDA, Porcupine, ChainRulesCore

function ChainRulesCore.rrule(::typeof(cu), a::Array{<:AbstractFloat})
    # @show ps
    y = cu(a)
    function pb(ȳ)
        NoTangent(), Array(ȳ)
    end
    return y, pb
end
function ChainRulesCore.rrule(::typeof(CUDA.fill), v, sz)
    y = CUDA.fill(v, sz)
    function pb(ȳ)
        NoTangent(), sum(ȳ), NoTangent()
    end
    return y, pb
end
end
