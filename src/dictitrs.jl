first(d::AbstractDict) = Base.first(Base.values(d))
first(d::NamedTuple) = Base.first(d)
first(x) = Base.first(x)

function keys(d)
    ignore_derivatives() do
        collect(Base.keys(d))
    end
end

values(x::NamedTuple) = collect(x)
values(x::Base.RefValue) = x[]
# values(d::AbstractDict) = collect(Base.values(d))
values(d::AbstractDict) = [d[k] for k in keys(d)]
values(x) = Base.values(x)
