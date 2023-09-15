using Functors
using UnPack
using StaticArrays, LinearAlgebra
# using NearestNeighbors

struct Grid
    cell::AbstractMatrix
    origin::AbstractVector
end
@functor Grid


"""
    Grid(resolutions, origin=ones(length(resolutions)))
    Grid(cell, origin=ones(size(cell, 1)))

Specifies regular grid of any dimension with its discretization cell and origin. For an orthogonal grid, supply a `Vector` of resolutions in each dimension. For non-orthogonal grid, supply the cell vectors as a column-wise matrix. Origin by default is at index (1, ...).

```
Grid(0.1) # 1d grid spaced 0.1 apart with origin at index 1
Grid([0.1, 0.2], [3,3]) # 2d grid spaced 0.1 along x and 0.2 along y, with origin at [3,3]
Grid(0.1 * [1 1 0; 1 0 1; 1 1 1]') # 3d grid with cell vectors [.1, .1, 0], [.1, 0, .1], [.1, .1, .1] (note matrix transpose). can construct lattice coordinates this way
```
"""
function Grid(cell::AbstractMatrix, origin=ones(eltype(cell), size(cell, 1)))
    Grid(cell, origin,)
end

function Grid(resolutions::AbstractVector, a...)
    Grid(Diagonal(resolutions), a...)
end

function Grid(dx::Real, origin::Real=1)
    Grid([dx], [origin])
end
