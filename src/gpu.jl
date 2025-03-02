T = AbstractArray{<:Number}
gpu(cu, d) = fmap(cu, d, T)
# gpu(d) = gpu(gpu_device(), d)
cpu(d) = fmap(Array, d, T)

