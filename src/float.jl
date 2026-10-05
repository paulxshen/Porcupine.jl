for F in (:(Base.Float16), :(Base.Float32), :(Base.Float64), :(Base.BFloat16))
    @eval $F(x::Str) = parse($F, string(x))
    @eval $F(d::Union{AbstractArray,Tuple,AbstractDict,NamedTuple}) = rmap($F, Number, d)
    @eval $F(x::$F) = x
    @eval $F(::Nothing) = nothing
    @eval $F(x::Complex) = complex($F)(x)
end


