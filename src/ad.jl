# keepfloat(x::AbstractFloat) = x
# keepfloat(x::Complex) = x
adfilter(x::Integer) = NoTangent()
adfilter(x::Bool) = NoTangent()
adfilter(x::String) = NoTangent()
adfilter(x::Symbol) = NoTangent()
adfilter(x) = x