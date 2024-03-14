# using 
Base.:+(x::AbstractArray, y::Number) = x .+ y
Base.:+(x::Number, y::AbstractArray) = x .+ y
Base.:-(x::AbstractArray, y::Number) = x .- y
Base.:-(x::Number, y::AbstractArray) = x .- y
VF = Union{AbstractVector{<:AbstractArray},Tuple,AbstractDict,NamedTuple}


function _keys(x::OrderedDict)
    k = 0
    ignore_derivatives() do
        k = keys(x) |> collect
    end
    k
end
_keys(x) = keys(x)

Base.:*(a::AbstractDict, b) = [a[k] .* b for (k, b) = zip(_keys(a), b)]
# broadcast(values(a), b) do a, b
#     a .* b
# end
Base.:*(a, b::AbstractDict) = b * a

Base.:*(a::VF, b::AbstractArray{<:Number}) = a * [b]
Base.:*(a::AbstractArray{<:Number}, b::VF) = [a] * b
Base.:/(a::VF, b::VF) =
    broadcast(values(a), values(b)) do a, b
        a ./ b
    end
Base.:/(a::VF, b::AbstractArray{<:Number}) = a / [b]
Base.:/(a::AbstractArray{<:Number}, b::VF) = [a] / b
