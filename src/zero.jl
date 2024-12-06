for (M, Z) = zip((:Base, :ChainRulesCore), (:Nothing, :ZeroTangent))
    @eval Base.:+(x::Map, y::$M.$Z) = x
    @eval Base.:+(x::$M.$Z, y::Map) = y

    # @eval Base.:-(x, y::$M.$Z) = x
    # @eval Base.:-(x::$M.$Z, y) = -y
    # @eval Base.:-(x::S, y::T) where {S<:$M.$Z,T<:$M.$Z} = S()

    # @eval Base.:*(x, y::T) where {T<:$M.$Z} = T()
    # @eval Base.:*(x::T, y) where {T<:$M.$Z} = T()
    # @eval Base.:*(x::S, y::T) where {S<:$M.$Z,T<:$M.$Z} = S()
end

Base.:+(x, y::Nothing) = x
Base.:+(x::Nothing, y) = y
Base.:+(x::Nothing, y::Nothing) = nothing

Base.:-(x, y::Nothing) = x
Base.:-(x::Nothing, y) = -y
Base.:-(x::Nothing, y::Nothing) = nothing

Base.:*(x, y::Nothing) = nothing
Base.:*(x::Nothing, y) = nothing
Base.:*(x::Nothing, y::Nothing) = nothing

# Base.zero(::Type{Any}) = 0