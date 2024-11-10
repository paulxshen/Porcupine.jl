for T = (:Map, :(AbstractVector{<:AbstractArray}))
    @eval Base.:*(A::AbstractMatrix{<:AbstractArray}, v::$T) = [sum([a .* v for (a, v) = zip(r, values(v))]) for r in eachrow(A)]
end
Base.:*(A::AbstractMatrix{<:AbstractArray}, B::AbstractMatrix{<:AbstractArray}) = [sum([a .* b for (a, b) = zip(r, c)]) for r = eachrow(A), c = eachcol(B)]

LinearAlgebra.norm(a::AbstractArray{<:AbstractArray}) = sqrt.(sum(a) do a
    a .⋅ a
end)
cdiff(a; dims) = selectdim(a, dims, 3:size(a, dims)) - selectdim(a, dims, 1:size(a, dims)-2)
grad(f, a) = [f(a; dims) for dims = 1:ndims(a)]
grad(a) = grad(diff, a)
cgrad(a) = [cdiff(a; dims)[[i == dims ? (:) : 2:size(a, i)-1 for i = 1:ndims(a)]...] for dims = 1:ndims(a)]
function hess(a)
    N = ndims(a)
    # g = grad(a)
    # h = [[diff(g[i]; dims) for dims = 1:i] for i = 1:N]
    # [j > i ? h[j][i] : h[i][j] for i = 1:N, j = 1:N]
    h = [(j == i ? diff(diff(a, dims=i), dims=i) : cdiff(cdiff(a, dims=i), dims=j))[[i == k || j == k ? (:) : 2:size(a, k)-1 for k = 1:ndims(a)]...] for i = 1:N, j = 1:N]
end