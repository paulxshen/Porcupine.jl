

divΔ(x::Real, dx::Real) = x / dx
divΔ(x::Real, deltas::AbstractArray{<:Real}) = indexof(cumsum(deltas), x)

function centroids(a::AbstractArray{<:Number}; dims=1)
    for i = dims
        a = (selectdim(a, i, 2:size(a, i)) + selectdim(a, i, 1:size(a, i)-1)) / 2
    end
    a
end
centroids(rulers) = Base.product(centroids.(rulers)...)

function centroidvals(a)
    for i = 1:ndims(a)
        a = (selectdim(a, i, 2:size(a, i)) + selectdim(a, i, 1:size(a, i)-1)) / 2
    end
    a
end