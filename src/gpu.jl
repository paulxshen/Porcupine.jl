gpu(cu, d) = rmap(cu, AbstractArray{<:Number}, d)
# gpu(d) = gpu(gpu_device(), d)
cpu(d) = rmap(Array, AbstractArray{<:Number}, d)

