xyz = ["x", "y", "z"]
function packxyz(d)
    ks = @ignore_derivatives sort(unique(first.(string.(keys(d)))))
    namedtuple(Symbol.(ks) .=> map(ks) do k
        map(k .* xyz) do k
            d(k, 0)
        end
    end)
end

function unpackxyz(d)
    namedtuple(reduce(vcat, map(keys(d)) do k
        Symbol.(string(k) .* xyz) .=> d[k]
    end))
end