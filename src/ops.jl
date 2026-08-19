for op in (:*, :/, :+, :-)
    @eval Base.$op(x, y) = $(op).(x, y)
end


Base.:!(x) = Base.:!.(x)
Base.:-(x) = 0 - x

Base.getindex(c::Base.Iterators.Zip, i::Integer) = collect(c)[i]

Base.:+(::NoTangent, y::Union{AbstractDict,NamedTuple}) = y
Base.:+(x::Union{AbstractDict,NamedTuple}, ::NoTangent) = x