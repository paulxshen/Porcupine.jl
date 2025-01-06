module ZygoteExt
using Porcupine
using Zygote: Buffer
setindexf!(a::Buffer{T}, v, I...; approx=false) where {T} = _setindexf!(T, a, v, I...; approx)
end
