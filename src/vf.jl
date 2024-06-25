VF = Union{AbstractVector{<:AbstractArray},Tuple,AbstractDict,NamedTuple,Base.RefValue}

# vfmul(a, b) = a.(.*)b
vfmul(a, b) = broadcast(.*, a, b)
Base.:*(a::VF, b::VF) = broadcast(.*, a, b)
Base.:*(a::VF, b::Dictlike) = broadcast(.*, a, values(b))
Base.:*(a::Dictlike, b::VF) = broadcast(.*, values(a), b)
# Base.:+(a::VF, b::AbstractArray) = a .+ [b]
# Base.:+(a::AbstractArray, b::VF) = [a] .+ b
# Base.:*(a::VF, b::AbstractArray) = a * [b]
# Base.:*(a::AbstractArray{<:Number}, b::VF) = [a] * b

# Base.:*(a::Dictlike, b::AbstractArray{<:Number}) = a * [b]
# Base.:*(a::AbstractArray{<:Number}, b::Dictlike) = vfmul([a], b)
# Base.:/(a::Dictlike, b::AbstractArray{<:Number}) = a / [b]
# Base.:*(a::AbstractArray{<:Number}, b::Dictlike) = vfmul([a], b)

function LinearAlgebra.cross(a::VF, b::VF)
    if length(a) == length(b) == 3
        u, v, w = b
        x, y, z = a
        return [w .* y - v .* z, u .* z - w .* x, v .* x - u .* y]
    elseif length(a) == 1 && length(b) == 2
        z, = a
        u, v, = b
        return [-v .* z, u .* z,]
    elseif length(a) == 2 && length(b) == 1
        return -b × a
    end
end

# function LinearAlgebra.dot(a::VF, b::VF)
#     if length(a) != length(b)
#         return fill(0, a |> values |> first |> size)
#     end
#     sum(a .⋅ b)
# end