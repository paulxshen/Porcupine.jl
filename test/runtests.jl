using Test
include("../src/operators.jl")

dx = 0.1
x = 0:dx:0.5
y = x .^ 2
d = Del(dx)
@test d(y) ≈ [0.2, 0.4, 0.6, 0.8]

dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
▽ = Del([dx, dy])
@test ▽(a) ≈ vcat(
    reshape([SVector(0.2, 0.2), SVector(0.2, 0.4), SVector(0.2, 0.6), SVector(0.2, 0.8)], 1, 4),
    reshape([SVector(0.4, 0.2), SVector(0.4, 0.4), SVector(0.4, 0.6), SVector(0.4, 0.8)], 1, 4),
    reshape([SVector(0.6, 0.2), SVector(0.6, 0.4), SVector(0.6, 0.6), SVector(0.6, 0.8)], 1, 4),
    reshape([SVector(0.8, 0.2), SVector(0.8, 0.4), SVector(0.8, 0.6), SVector(0.8, 0.8)], 1, 4),
)

dy = dx = 0.1
a = [x^2 + y^2 for x in 0:dx:0.5, y in 0:dy:0.5]
▽2 = Lap([dx, dy])
@test ▽2(a) ≈ [
    4.0 4.0 4.0 4.0
    4.0 4.0 4.0 4.0
    4.0 4.0 4.0 4.0
    4.0 4.0 4.0 4.0]