T = AbstractArray{<:Number}
_cpu(x::T) = Array(x)
_gpu(cu, x::T) = cu(x)
_gpu(cu, x) = x
_cpu(x) = x
gpu(cu, d) = fmap(x -> _gpu(cu, x), d, T)
cpu(d) = fmap(_cpu, d, T)

