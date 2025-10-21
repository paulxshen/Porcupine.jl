first(d::AbstractDict) = Base.first(values(d))
first(d::NamedTuple) = Base.first(d)
first(x) = Base.first(x)

function keys(d)
    ignore_derivatives() do
        collect(Base.keys(d))
    end
end

_values(x::NamedTuple) = collect(x)
_values(x::Base.RefValue) = x[]
_values(x) = values(x)

Base.broadcastable(x::AbstractDict) = _values(x)
Base.broadcastable(x::SortedDict) = _values(x)
Base.broadcastable(x::OrderedDict) = _values(x)
Base.broadcastable(x::NamedTuple) = collect(x)

rcopy!(x::AbstractArray{<:Number}, y::AbstractArray{<:Number}) = copy!(x, y)
rcopy!(x, y) = rcopy!.(_values(x), _values(y))

Base.getindex(v::Base.ValueIterator, i) = collect(v)[i]