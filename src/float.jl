Base.Float16(x::Dictlike) = f16(x)
Base.Float32(x::Dictlike) = f32(x)

Base.Float16(x::List) = Float16.(x)
Base.Float32(x::List) = Float32.(x)
Base.Float64(x::List) = Float64.(x)

Base.Float16(x::AbstractArray{<:Complex}) = ComplexF16.(x)
Base.Float32(x::AbstractArray{<:Complex}) = ComplexF32.(x)
Base.Float64(x::AbstractArray{<:Complex}) = ComplexF64.(x)

Base.Float16(x::Complex) = ComplexF16(x)
Base.Float32(x::Complex) = ComplexF32(x)
Base.Float64(x::Complex) = ComplexF64(x)

Base.Float16(x::Str) = parse(Float16, string(x))
Base.Float32(x::Str) = parse(Float32, string(x))
Base.Float64(x::Str) = parse(Float64, string(x))