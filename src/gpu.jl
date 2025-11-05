gpu(cu, d) = fmap(cu, d)
# gpu(d) = gpu(gpu_device(), d)
cpu(d) = fmap(Array, d)

