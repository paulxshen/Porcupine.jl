using ArrayPadding, LinearAlgebra
include("grid.jl")
include("conv.jl")

struct Op
    kernel::AbstractArray
end
@functor Op

function (m::Op)(a, p=*)
    r = conv(m.kernel, a, p)[[i:j for (i, j) in zip(size(m.kernel), size(a))]...]
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
function Del(a, centered=true)
    cell = Grid(a).cell
    d = size(cell, 1)

    kernel = centered ? [1, 0, -1] / 2 : [1, -1]
    if d == 1
        kernel /= cell[1]
    else
        kernel = [
            SVector{d}(sum(abs.(v)) > 1 ? zeros(d) : cell' \ collect(v))
            for v in Iterators.product(fill(kernel, d)...)
        ]
    end
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
    d = size(cell, 1)

    kernel = Del(cell).kernel
    kernel = [
        conv(kernel, kernel, :dot)[i...]
        for i in Iterators.product(fill((1, 3, 5), d)...)
    ] * 4

    return Op(kernel)
end

function Op(radfunc, a, rmax::Real, l::Int=0; kw...)
    cell = Grid(a).cell
    lims = ceil.(Int, rmax ./ norm.(eachcol(cell)))
    d = length(lims)
    kernel = det(cell) * map(Iterators.product([-i:i for i = lims]...)) do I
        v = cell * collect(I)
        r = norm(v)
        if l == 0
            return r > rmax ? 0 : radfunc(r)
        elseif l == 1
            return SVector{d}(r > rmax || r == 0 ? zeros(d) : radfunc(r) / r * v)
        end
    end
    Op(kernel)
end
"""
    Gauss(σ, resolutions, rmax=3σ)
    Gauss(σ, cell, rmax=3σ)

constructs Gaussian blur operator with volume Normalized to 1 wrt grid support
"""
function Gauss(σ, a, rmax=3σ)
    cell = Grid(a).cell
    radfunc = r -> exp(-r^2 / (2 * σ^2)) / sqrt((2π * σ^2)^size(cell, 1))
    return Op(radfunc, cell, rmax,)
end

