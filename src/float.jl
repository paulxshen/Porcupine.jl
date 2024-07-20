Base.Float16(x::List) = Float16.(x)
Base.Float32(x::List) = Float32.(x)
Base.Float64(x::List) = Float64.(x)

Base.Float16(x::AbstractArray{<:Complex}) = ComplexF16.(x)
Base.Float32(x::AbstractArray{<:Complex}) = ComplexF32.(x)
Base.Float64(x::AbstractArray{<:Complex}) = ComplexF64.(x)

Base.Float16(x::Complex) = ComplexF16(x)
Base.Float32(x::Complex) = ComplexF32(x)
Base.Float64(x::Complex) = ComplexF64(x)

Base.Float16(x::Str) = all(isdigit, string(x)) ? parse(Float16, string(x)) : x
Base.Float32(x::Str) = all(isdigit, string(x)) ? parse(Float32, string(x)) : x
Base.Float64(x::Str) = all(isdigit, string(x)) ? parse(Float64, string(x)) : x

f16(x) = Float16(x)
f32(x) = Float32(x)
f64(x) = Float64(x)

Base.Float16(d::Dictlike) = apply(f16, d)
Base.Float32(d::Dictlike) = apply(f32, d)
Base.Float64(d::Dictlike) = apply(f64, d)

Base.Float16(x) = x
Base.Float32(x) = x
Base.Float64(x) = x

Base.Float16(x::Float16) = x
Base.Float32(x::Float32) = x
Base.Float64(x::Float64) = x
