using Test, Porcupine, StaticArrays, LinearAlgebra
atol = 1e-6

dx = 0.1
x = 0:dx:0.5
y = x .^ 2
d = Del(dx)
@test d(y) ≈ [0.2, 0.4, 0.6, 0.8]
d = Del(dx, false)
@test d(y) ≈ diff(y)

dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
∇ = Del([dx, dy])
@test ∇(a) ≈ vcat(
    reshape([SVector(0.2, 0.2), SVector(0.2, 0.4), SVector(0.2, 0.6), SVector(0.2, 0.8)], 1, 4),
    reshape([SVector(0.4, 0.2), SVector(0.4, 0.4), SVector(0.4, 0.6), SVector(0.4, 0.8)], 1, 4),
    reshape([SVector(0.6, 0.2), SVector(0.6, 0.4), SVector(0.6, 0.6), SVector(0.6, 0.8)], 1, 4),
    reshape([SVector(0.8, 0.2), SVector(0.8, 0.4), SVector(0.8, 0.6), SVector(0.8, 0.8)], 1, 4),
)

dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
∇2 = Lap([dx, dy])
@test ∇2(a) ≈ [
    4.0 4.0 4.0 4.0
    4.0 4.0 4.0 4.0
    4.0 4.0 4.0 4.0
    4.0 4.0 4.0 4.0]

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
@test ∇ ⋅ a ≈ [0]' atol = atol
@test ∇ × a ≈ [-2]' atol = atol

g = Gauss(1, [0.1, 0.1])
@test sum(g.kernel) ≈ 1 atol = 0.05