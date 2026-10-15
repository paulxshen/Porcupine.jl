

divΔ(x::Real, dx::Real) = x / dx
divΔ(x::Real, deltas::AbstractArray{<:Real}) = indexof(cumsum(deltas), x)

function _centroids(a, dims)
    for i = dims
        a = (selectdim(a, i, 2:size(a, i)) + selectdim(a, i, 1:size(a, i)-1)) / 2
    end
    a
end
centroids(a::AbstractArray{<:Number}; dims=1) = _centroids(a, dims)
centroids(rulers) = Base.product(centroids.(rulers)...)
centroidvals(a) = _centroids(a, 1:ndims(a))