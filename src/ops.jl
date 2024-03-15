# using 
Base.:+(x::AbstractArray, y::Number) = x .+ y
Base.:+(x::Number, y::AbstractArray) = x .+ y
Base.:-(x::AbstractArray, y::Number) = x .- y
Base.:-(x::Number, y::AbstractArray) = x .- y
VF = Union{AbstractVector{<:AbstractArray},Tuple,AbstractDict,NamedTuple}


function keys(x)
    ignore_derivatives() do
        Base.keys(x) |> collect
    end
end

function _values(x::AbstractDict)
    [x[k] for k = keys(x)]
end
_values(x) = values(x)

dmul(a, b) = [a[k] .* b for (k, b) = zip(keys(a), b)]
Base.:*(a::AbstractDict, b) = dmul(a, b)
Base.:*(a::AbstractDict, b::AbstractDict) = dmul(a, b)
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
