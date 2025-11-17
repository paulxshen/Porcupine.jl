for F in (:(Base.Float16), :(Base.Float32), :(Base.Float64), :(BFloat16s.BFloat16))
    @eval Base.convert(::Type{$F}, x::Str) = parse($F, string(x))
    @eval $F(x::Str) = parse($F, string(x))
    @eval $F(x::ArrayLike) = ($F).(x)
    # @eval $F(x) = ($F).(x)
    @eval $F(d::Map) = rmap($F, d)
    @eval $F(x::$F) = x
    @eval $F(::Nothing) = nothing
    @eval $F(x::AbstractArray{<:Complex}) = complex($F).(x)
    @eval $F(x::Complex) = complex($F)(x)
end


