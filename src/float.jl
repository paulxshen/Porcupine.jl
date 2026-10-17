for F in (:(Base.Float16), :(Base.Float32), :(Base.Float64), :(Core.BFloat16))
    @eval $F(x::Str) = parse($F, string(x))
    @eval $F(c) = rmap($F, Union{AbstractFloat,Complex}, c)
    @eval $F(x::Number) =convert($F,x)
    @eval $F(x::Base.TwicePrecision) = $F(x.hi + x.lo)
    @eval $F(x::$F) = x
    @eval $F(::Nothing) = nothing
    @eval $F(x::Complex) = complex($F)(x)
end


