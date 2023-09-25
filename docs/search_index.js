var documenterSearchIndex = {"docs":
[{"location":"#Porcupine.jl","page":"Porcupine.jl","title":"Porcupine.jl","text":"","category":"section"},{"location":"","page":"Porcupine.jl","title":"Porcupine.jl","text":"Finite difference operators on scalar and vector fields including derivative, gradient, divergence, curl and exterior derivative in 1d/2d/3d. Optional smooth padding for maintaining same ouput size as input. Scalar fields are arrays while vector fields are represented as arrays of static vectors","category":"page"},{"location":"","page":"Porcupine.jl","title":"Porcupine.jl","text":"Del\nLap","category":"page"},{"location":"#Porcupine.Del","page":"Porcupine.jl","title":"Porcupine.Del","text":"Del(resolutions::AbstractVector)\nDel(cell::AbstractMatrix)\n\nconstructs ∇ operator (derivative, gradient, divergence, curl) using central difference stencil. Because the stencil is of length 3 in each dimension, the result is 2 elements shorter in each dimension than the input. To instead retain the same size, use border=:smooth which pads the input\n\nExample\n\n1d derivative\n\ndx = 0.1\nx = 0:dx:.5\ny = x .^ 2\nd = Del(dx)\n@test d(y)≈[ 0.2, 0.4,0.6,0.8]\n@test d(y, border=:smooth) ≈ [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]\n\n2d gradient\n\ndy = dx = 0.1\na = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]\n∇ = Del([dx, dy])\n∇(a)\n\n#=\n4×4 Matrix{SVector{2, Float64}}:\n [0.2, 0.2]  [0.2, 0.4]  [0.2, 0.6]  [0.2, 0.8]\n [0.4, 0.2]  [0.4, 0.4]  [0.4, 0.6]  [0.4, 0.8]\n [0.6, 0.2]  [0.6, 0.4]  [0.6, 0.6]  [0.6, 0.8]\n [0.8, 0.2]  [0.8, 0.4]  [0.8, 0.6]  [0.8, 0.8]\n=#\n\n2d divergence, curl\n\ncurl of 2d Vector field is taken to be vorticity scalar field. In 3d curl produces vorticity vector field.\n\na = collect.([\n    (0, 0) (-1, 0) (0, 0)\n    (0, -1) (0, 0) (0, 1)\n    (0, 0) (1, 0) (0, 0)\n])\n∇ = Del([1, 1])\n@test ∇ ⋅ a ≈ ∇(a, dot) ≈ [2]'\n@test ∇ × a ≈ ∇(a, cross) ≈ [0]'\n\na = collect.([\n    (0, 0) (0, 1) (0, 0)\n    (-1, 0) (0, 0) (1, 0)\n    (0, 0) (0, -1) (0, 0)\n])\n∇ = Del([1, 1])\n@test ∇ ⋅ a ≈ [0]' \n@test ∇ × a ≈ [-2]' \n\n\n\n\n\n","category":"function"},{"location":"#Porcupine.Lap","page":"Porcupine.jl","title":"Porcupine.Lap","text":"Lap(resolutions::AbstractVector)\nLap(cell::AbstractMatrix)\n\nconstructs Laplacian operator\n\n# 2d Example\ndy = dx = 0.1\na = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]\n∇2 = Lap([dx, dy])\n∇2(a)\n\n#=\n4x4 Matrix{Float64}:\n   4.0  4.0  4.0  4.0  \n   4.0  4.0  4.0  4.0  \n   4.0  4.0  4.0  4.0  \n   4.0  4.0  4.0  4.0  \n=#\n\n\n\n\n\n","category":"function"},{"location":"#Contributors","page":"Porcupine.jl","title":"Contributors","text":"","category":"section"},{"location":"","page":"Porcupine.jl","title":"Porcupine.jl","text":"Paul Shen, MLE EE, Stanford MS EE, pxshen@alumni.stanford.edu","category":"page"}]
}