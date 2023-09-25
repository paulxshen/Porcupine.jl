using ArrayPadding, LinearAlgebra
include("grid.jl")
include("conv.jl")

struct Op
    kernel::AbstractArray
end
@functor Op

function (m::Op)(a, p...; border=nothing)
    if border !== nothing
        s = (size(m.kernel) .- 1) .÷ 2
        if border !== :smooth
            a = pad(a, border, s)
        end
    end
    r = conv(m.kernel, a, p...)[[i:j for (i, j) in zip(size(m.kernel), size(a))]...]
    if border == :smooth && all(s .== 1)
        r = pad(r, :smooth, s)
    end
    r
end

function LinearAlgebra.dot(m::Op, a::AbstractArray)
    m(a, dot)
end

function LinearAlgebra.cross(m::Op, a::AbstractArray)
    m(a, cross)
end

"""
    Del(resolutions::AbstractVector)
    Del(cell::AbstractMatrix)

constructs ∇ operator (derivative, gradient, divergence, curl) using central difference stencil. Because the stencil is of length 3 in each dimension, the result is 2 elements shorter in each dimension than the input. To instead retain the same size, use `border=:smooth` which pads the input

# Example
## 1d derivative
```
dx = 0.1
x = 0:dx:.5
y = x .^ 2
d = Del(dx)
@test d(y)≈[ 0.2, 0.4,0.6,0.8]
@test d(y, border=:smooth) ≈ [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
```

## 2d gradient
```
dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
∇ = Del([dx, dy])
∇(a)

#=
4×4 Matrix{SVector{2, Float64}}:
 [0.2, 0.2]  [0.2, 0.4]  [0.2, 0.6]  [0.2, 0.8]
 [0.4, 0.2]  [0.4, 0.4]  [0.4, 0.6]  [0.4, 0.8]
 [0.6, 0.2]  [0.6, 0.4]  [0.6, 0.6]  [0.6, 0.8]
 [0.8, 0.2]  [0.8, 0.4]  [0.8, 0.6]  [0.8, 0.8]
=#
```

## 2d divergence, curl
curl of 2d Vector field is taken to be vorticity scalar field. In 3d curl produces vorticity vector field.
```
a = collect.([
    (0, 0) (-1, 0) (0, 0)
    (0, -1) (0, 0) (0, 1)
    (0, 0) (1, 0) (0, 0)
])
∇ = Del([1, 1])
@test ∇ ⋅ a ≈ ∇(a, dot) ≈ [2]'
@test ∇ × a ≈ ∇(a, cross) ≈ [0]'

a = collect.([
    (0, 0) (0, 1) (0, 0)
    (-1, 0) (0, 0) (1, 0)
    (0, 0) (0, -1) (0, 0)
])
∇ = Del([1, 1])
@test ∇ ⋅ a ≈ [0]' 
@test ∇ × a ≈ [-2]' 
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
∇2 = Lap([dx, dy])
∇2(a)

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
        conv(kernel, kernel, :dot)[i...]
        for i in Iterators.product(fill((1, 3, 5), dims)...)
    ] * 4

    return Op(kernel)
end

function Op(radfunc, rmax, a, l=0; kw...)
    cell = Grid(a).cell
end
"""
    Gauss(resolutions, σ, rmax; kw...)
    Gauss(cell, σ, rmax; kw...)

constructs Gaussian blur operator with volume Normalized to 1 wrt grid support
"""
function Gauss(a, σ; rmax=2σ, kw...)
    cell = Grid(a).cell
    radfunc = r -> exp(-r^2 / (2 * σ^2)) / sqrt((2π * σ^2)^size(cell, 1))
    return Op(radfunc, rmax, cell; kw...)
end

