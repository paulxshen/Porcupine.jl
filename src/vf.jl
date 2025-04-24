for T = (:Map, :(AbstractVector{<:AbstractArray}))
    @eval Base.:*(A::AbstractMatrix{S}, v::$T) where {S<:Union{Number,AbstractArray}} =
        map(eachrow(A)) do r
            # sum(r .⊙ values(v))
            sum(map(r, values(v)) do a, b
                a .* b
            end)
        end
end
Base.:*(A::AbstractMatrix{<:AbstractArray}, B::AbstractMatrix{<:AbstractArray}) = [sum([a .* b for (a, b) = zip(r, c)]) for r = eachrow(A), c = eachcol(B)]

LinearAlgebra.norm(a::VectorField) = sqrt.(sum(values(a)) do a
    a .⋅ a
end)
