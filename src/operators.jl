using Functors
# using Zygote

include("grid.jl")
include("conv.jl")

struct Op
    kernel::AbstractArray
end
@functor Op

function (m::Op)(a)
    conv(a, m.kernel)[[i:j for (i, j) in zip(size(m.kernel), size(a))]...]
end

"""
    Del(resolutions::AbstractVector)
    Del(cell::AbstractMatrix)

constructs ∇ operator (derivative, gradient, divergence, curl) using central difference stencil. Because the stencil is of length 3 in each dimension, the result is 2 elements shorter in each dimension than the input.

# Example
## 1d derivative
```
dx = 0.1
x = 0:dx:.5
y = x .^ 2
d = Del(dx)
@test d(y)≈[ 0.2, 0.4,0.6,0.8]
```

## 2d gradient
```
dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
▽ = Del([dx, dy])
▽(a)

#=
4×4 Matrix{SVector{2, Float64}}:
 [0.2, 0.2]  [0.2, 0.4]  [0.2, 0.6]  [0.2, 0.8]
 [0.4, 0.2]  [0.4, 0.4]  [0.4, 0.6]  [0.4, 0.8]
 [0.6, 0.2]  [0.6, 0.4]  [0.6, 0.6]  [0.6, 0.8]
 [0.8, 0.2]  [0.8, 0.4]  [0.8, 0.6]  [0.8, 0.8]
=#
```
"""
function Del(a)
    cell = Grid(a).cell
    dims = size(cell, 1)

    if dims == 1
        kernel = [1, 0, -1] / 2 / cell[1]
    else
        kernel = [
            SVector{dims}(sum(abs.(v)) > 1 ? zeros(dims) : -cell' \ collect(v) / 2)
            for v in Iterators.product(fill(-1:1, dims)...)
        ]
    end
    # kernel /= det(grid.cell)
    return Op(kernel)
end

"""
    Lap(resolutions::AbstractVector)
    Lap(cell::AbstractMatrix)

constructs Laplacian operator

```
# 2d Example
dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
▽2 = Lap([dx, dy])
▽2(a)

#=
4x4 Matrix{Float64}:
   4.0  4.0  4.0  4.0  
   4.0  4.0  4.0  4.0  
   4.0  4.0  4.0  4.0  
   4.0  4.0  4.0  4.0  
=#
```
"""
function Lap(a)
    cell = Grid(a).cell
    dims = size(cell, 1)

    kernel = Del(cell).kernel
    kernel = [
        conv(kernel, kernel)[i...]
        for i in Iterators.product(fill((1, 3, 5), dims)...)
    ] * 4

    return Op(kernel)
end

"""
    Gauss(resolutions, σ, rmax; kw...)
    Gauss(cell, σ, rmax; kw...)

constructs Gaussian diffusion operator with volume Normalized to 1 wrt grid support
"""
function Gauss(a, σ; rmax=2σ, kw...)
    cell = Grid(a).cell
    radfunc = r -> exp(-r^2 / (2 * σ^2)) / sqrt((2π * σ^2)^size(cell, 1))
    return Op(radfunc, rmax, cell; kw...)
end
