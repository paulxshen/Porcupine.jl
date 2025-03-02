module ZygoteExt
using Porcupine
using Zygote: Buffer
place!(a::Buffer{T}, v, I...; approx=false) where {T} = _place!(T, a, v, I...; approx)
end
