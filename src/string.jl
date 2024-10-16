Base.length(::Symbol) = 1
# Base.iterate(s::Symbol, i=1) = i > 1 ? nothing : (s, i + 1)
Base.getindex(s::Symbol, i) = Symbol(String(s)[i])
Base.convert(::Type{Symbol}, x::String) = Symbol(x)
Base.convert(::Type{String}, x::Symbol) = string(x)



Base.startswith(s, x) = startswith(string(s), string(x))
