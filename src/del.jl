macro nograd(ex)
    quote
        $(esc(ex)) = ignore_derivatives() do
            $(esc(ex))
        end
    end
end

function cdiff(a; dims=1)
    n = size(a, dims)
    (selectdim(a, dims, 3:n) - selectdim(a, dims, 1:(n-2))) / 2
end
Base.diff(x::Number, args...; kw...) = 0
cdiff(x::Number, args...; kw...) = 0
Base.diff(a, i) = diff(a, dims=i)
cdiff(a, i) = cdiff(a; dims=i)




