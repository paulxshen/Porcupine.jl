
Base.getindex(s::Symbol, i) = Symbol(String(s)[i])
Base.convert(::Type{Symbol}, x::String) = Symbol(x)
Base.convert(::Type{String}, x::Symbol) = string(x)

Base.convert(F::Type{Float64}, x::String) = parse(F, x)
Base.convert(F::Type{Float32}, x::String) = parse(F, x)
Base.convert(F::Type{Float16}, x::String) = parse(F, x)

Base.convert(F::Type{Float16}, x::Symbol) = parse(F, string(x))
Base.convert(F::Type{Float32}, x::Symbol) = parse(F, string(x))
Base.convert(F::Type{Float64}, x::Symbol) = parse(F, string(x))


Base.Float16(x::Str) = parse(Float16, string(x))
Base.Float32(x::Str) = parse(Float32, string(x))
Base.Float64(x::Str) = parse(Float64, string(x))
