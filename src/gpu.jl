T = AbstractArray{<:Number}
_cpu(x::T) = Array(x)
_gpu(x::T, cu) = cu(x)
_gpu(x) = x
_cpu(x) = x
gpu(cu, d) = fmap(x -> _gpu(x, cu), d, T)
cpu(d) = fmap(_cpu, d, T)

