using Zygote

# grid = RectangleGrid([0.0, 0.5, 1.0], [0.0, 0.5, 1.0])  # rectangular grid
# sGrid = SimplexGrid([0.0, 0.5, 1.0], [0.0, 0.5, 1.0])# simplex grid
# gridData = [8.0, 1.0, 6.0, 3.0, 5.0, 7.0, 4.0, 9.0, 2.0]   # vector of value data at each cut
# x = [0.25, 0.75]  # point at which to perform interpolation
# f(x) = interpolate(grid, gridData, x)

# a = ones(10, 10, 10);
# using Interpolations
# itp = interpolate(a, BSpline(Linear()));

# f(x) = itp(x...)
using FFTW, Random, Flux
using CairoMakie
Random.seed!(1)
n = 64
dims = (n, n)
x = complex.(randn(dims), randn(dims))
x = x + circshift(reverse(conj.(x)), ones(Int, length(dims)))
f(x) = x |> ifft |> real |> σ
# Zygote.gradient(f, x)
heatmap(f(x))