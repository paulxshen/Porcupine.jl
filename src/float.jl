Base.Float16(x::List) = Float16.(x)
Base.Float32(x::List) = Float32.(x)
Base.Float64(x::List) = Float64.(x)

Base.Float16(x::AbstractArray{<:Complex}) = ComplexF16.(x)
Base.Float32(x::AbstractArray{<:Complex}) = ComplexF32.(x)
Base.Float64(x::AbstractArray{<:Complex}) = ComplexF64.(x)

Base.Float16(x::Complex) = ComplexF16(x)
Base.Float32(x::Complex) = ComplexF32(x)
Base.Float64(x::Complex) = ComplexF64(x)

f16(x) = Float16(x)
f32(x) = Float32(x)
f64(x) = Float64(x)

Base.Float16(d::Map) = apply(f16, d)
Base.Float32(d::Map) = apply(f32, d)
Base.Float64(d::Map) = apply(f64, d)

# Base.Float16(x) = x
# Base.Float32(x) = x
# Base.Float64(x) = x

Base.Float16(x::Float16) = x
Base.Float32(x::Float32) = x
Base.Float64(x::Float64) = x
