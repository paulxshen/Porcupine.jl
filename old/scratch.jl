include("main.jl")
a = [norm(collect(Tuple(i)) - [10, 10]) < 5 for i = CartesianIndices((20, 20))]
g = cgrad(a)
ng = norm(g)
n = g ⊘ ([ng + (ng .== 0)])
t = [-n[2], n[1]]
h = hess(a)
k = norm(h * t)
# f, _, p = heatmap(k)
# Colorbar!(f[1, 2], p)