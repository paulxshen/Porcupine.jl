for F in (:(Base.Float16), :(Base.Float32), :(Base.Float64))
    @eval Base.convert(::Type{$F}, x::Str) = parse($F, string(x))
    @eval $F(x::Str) = parse($F, string(x))
    @eval $F(x::Container) = ($F).(x)
    @eval $F(d::Map) = fmap($F, d)
    @eval $F(x::$F) = x
    @eval $F(::Nothing) = nothing
end


Base.Float16(x::AbstractArray{<:Complex}) = ComplexF16.(x)
Base.Float32(x::AbstractArray{<:Complex}) = ComplexF32.(x)
Base.Float64(x::AbstractArray{<:Complex}) = ComplexF64.(x)
# Bfloat16s.BFloat16(x::AbstractArray{<:Complex}) = ComplexBF16.(x)

Base.Float16(x::Complex) = ComplexF16(x)
Base.Float32(x::Complex) = ComplexF32(x)
Base.Float64(x::Complex) = ComplexF64(x)


# f16(x) = Float16(x)
# f32(x) = Float32(x)
# f64(x) = Float64(x)

# Base.Int(x::TrackedFloat32) = Int(Float32(x))