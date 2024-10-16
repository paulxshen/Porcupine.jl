for F in (:Float16, :Float32, :Float64)
    @eval Base.convert(F::Type{$F}, x::Text) = parse(F, string(x))
    @eval Base.$F(x::Text) = parse($F, string(x))
end

Base.Float16(x::Container) = Float16.(x)
Base.Float32(x::Container) = Float32.(x)
Base.Float64(x::Container) = Float64.(x)

Base.Float16(x::AbstractArray{<:Complex}) = ComplexF16.(x)
Base.Float32(x::AbstractArray{<:Complex}) = ComplexF32.(x)
Base.Float64(x::AbstractArray{<:Complex}) = ComplexF64.(x)

Base.Float16(x::Complex) = ComplexF16(x)
Base.Float32(x::Complex) = ComplexF32(x)
Base.Float64(x::Complex) = ComplexF64(x)

Base.Float16(d::Map) = fmap(Base.Float16, d)
Base.Float32(d::Map) = fmap(Base.Float32, d)
Base.Float64(d::Map) = fmap(Base.Float64, d)

Base.Float16(x::Float16) = x
Base.Float32(x::Float32) = x
Base.Float64(x::Float64) = x

f16(x) = Float16(x)
f32(x) = Float32(x)
f64(x) = Float64(x)

# Base.Int(x::TrackedFloat32) = Int(Float32(x))