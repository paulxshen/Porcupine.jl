for T = (:Map, :(AbstractVector{<:AbstractArray}))
    @eval Base.:*(A::AbstractMatrix{S}, v::$T) where {S<:Union{Number,AbstractArray}} =
        map(eachrow(A)) do r
            # sum(r .⊙ values(v))
            sum(map(r, values(v)) do a, b
                a .* b
            end)
        end
end
# Base.:*(A::AbstractMatrix{<:AbstractArray}, B::Vector{<:AbstractArray})
_vfmul(A, B) =
    map(Base.product(eachrow(A), eachcol(B))) do (r, c)
        mapreduce(⊙, +, r, c)
    end
Base.:*(A::AbstractMatrix{<:AbstractArray}, B::AbstractMatrix{<:AbstractArray}) = _vfmul(A, B)
Base.:*(A::AbstractVector{<:AbstractArray}, B::AbstractMatrix{<:AbstractArray}) = _vfmul(A, B)
Base.:*(A::AbstractMatrix{<:AbstractArray}, B::AbstractVector{<:AbstractArray}) = _vfmul(A, B) |> vec
# Base.:*(A::Vector, B::Adjoint) = _vm(A, B)
# Base.:*(A::Vector{<:AbstractArray}, B::Adjoint{<:AbstractArray,<:AbstractVector}) = _vm(A, B)

LinearAlgebra.norm(a::VectorField) = sqrt.(sum(values(a)) do a
    a .⋅ a
end)
