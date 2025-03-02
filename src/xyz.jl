xyz = ["x", "y", "z"]
function packxyz(d)
    N = ndims(d(1))
    ks = @ignore_derivatives sort(unique(first.(string.(keys(d)))))
    namedtuple(Symbol.(ks) .=> map(ks) do k
        map(k .* xyz[1:N]) do k
            d(k, 0)
        end
    end)
end

function unpackxyz(d)
    namedtuple(reduce(vcat, map(pairs(d)) do (k, v)
        N = length(v)
        Symbol.(string(k) .* xyz[1:N]) .=> v
    end))
end