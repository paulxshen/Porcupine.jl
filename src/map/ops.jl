__f(f, x, y) =
    broadcast(keys(x), values(y)) do k, v
        k => f(x[k], v)
    end
kmap(f, x::NamedTuple, y) = namedtuple(__f(f, x, y))
kmap(f, x::AbstractDict, y) = dict(__f(f, x, y))

Base.:+(x::T, y) where {T<:Map} = kmap(+, x, y)
Base.:+(x, y::T) where {T<:Map} = y + x
Base.:+(x::S, y::T) where {S<:Map,T<:Map} = kmap(+, x, y)

Base.:*(x::T, y) where {T<:Map} = kmap(*, x, y)
Base.:*(x, y::T) where {T<:Map} = y * x
Base.:*(x::T, y::S) where {S<:Map,T<:Map} = kmap(*, x, y)

Base.:-(x::T,) where {T<:Map} = 0 - x
Base.:-(x::T, y) where {T<:Map} = kmap(-, x, y)
Base.:-(x, y::T) where {T<:Map} = kmap((x, y) -> y - x, y, x) #- (y - x)
Base.:-(x::T, y::S) where {S<:Map,T<:Map} = kmap(-, x, y)


Base.:/(x::T, y) where {T<:Map} = kmap(/, x, y)
Base.:/(x, y::T) where {T<:Map} = kmap((x, y) -> y / x, y, x)
Base.:/(x::T, y::S) where {S<:Map,T<:Map} = kmap(/, x, y)

⊗(x::T, y::S) where {T<:AbstractArray{<:Number},S<:AbstractArray{<:Number}} = x .* y
⊗(x, y) = x * y
⊘(x::T, y::S) where {T<:AbstractArray{<:Number},S<:AbstractArray{<:Number}} = x ./ y
⊘(x, y) = x / y

Base.:⊗(x::Map, y) = kmap(⊗, x, y)
Base.:⊗(x, y::Map) = y ⊗ x
Base.:⊗(x::T, y::S) where {S<:Map,T<:Map} = kmap(⊗, x, y)

Base.:⊘(x::Map, y) = kmap(⊘, x, y)
Base.:⊘(x, y::Map) = kmap((x, y) -> y ⊘ x, y, x)
Base.:⊘(x::T, y::S) where {S<:Map,T<:Map} = kmap(⊘, x, y)
# ⊙(x, y) = x * y
