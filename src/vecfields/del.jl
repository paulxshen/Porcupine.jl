function pdiff(a, vl=nothing, vr=nothing; dims)
    sel = 1:ndims(a) .== dims
    l = !isnothing(vl)
    r = !isnothing(vr)
    # T = eltype(a)
    # zsz = size(a) .* (1 - select) + select |> Tuple
    # z = zeros(T, zsz)
    # if !isnothing(l)
    #     # if l == 1
    #     return cat(z, diff(a; dims=dims), dims=dims)
    # elseif !isnothing(r)
    #     # elseif r == 1
    #     return cat(diff(a; dims=dims), z, dims=dims)
    # end
    _a = Buffer(a, Tuple(size(a) + (l + r - 1) * sel))
    # a = diff(a; dims)
    _a[[i == 0 ? (:) : l+1:size(_a, dims)-r for i = sel]...] = diff(a; dims)
    if l > 0
        # a = pad(a, l, sel, 0; dims)
        pad!(_a, vl, sel, 0)
    end
    if r > 0
        pad!(_a, vr, 0, sel)
    end
    copy(_a)
end
pdiff(a, diffpadvals::AbstractMatrix; dims) = pdiff(a, diffpadvals[dims, :]...; dims)

struct Del
    Δ::List
    diffpadvals
    # function Del(Δ, diffpadvals, alg=nothing)
    #     new(Δ, diffpadvals, alg)
    # end
end

function LinearAlgebra.cross(m::Del, d::Map)
    @unpack Δ, diffpadvals = m
    ks = keys(d)
    ps = getindex.((diffpadvals,), keys(d))
    as = values(d)
    N = length(Δ)
    # if p == dot
    #     return sum([pdiff(a[i], dims=i) for i = 1:n] ./ Δ)
    if N == 2
        dx, dy = Δ
        if length(as) == 1
            u, = as
            pu, = ps
            ku, = ks
            return [pdiff(u, pu; dims=2) ./ dy[ku], -pdiff(u, pu; dims=1) ./ dx[ku]]
        elseif length(as) == 2
            u, v = as
            pu, pv = ps
            ku, kv = ks
            return [pdiff(v, pv; dims=1) ./ dx[kv] - pdiff(u, pu; dims=2) ./ dy[ku]]
        end
    elseif N == 3
        dx, dy, dz = Δ
        u, v, w = as
        pu, pv, pw = ps
        ku, kv, kw = ks
        uy = pdiff(u, pu; dims=2) ./ dy[ku]
        uz = pdiff(u, pu; dims=3) ./ dz[ku]
        vx = pdiff(v, pv; dims=1) ./ dx[kv]
        vz = pdiff(v, pv; dims=3) ./ dz[kv]
        wx = pdiff(w, pw; dims=1) ./ dx[kw]
        wy = pdiff(w, pw; dims=2) ./ dy[kw]
        return [wy - vz, uz - wx, vx - uy]
    end
end
# function LinearAlgebra.dot(m::Del, a)
#     m(a, dot)
# end

# struct Laplacian
#     Δ::AbstractArray
# end
# function lap(a::AbstractArray, ; dims=1)
#     select = 1:ndims(a) .== dims
#     circshift(a, -select) - 2a + circshift(a, select)
# end
# function cdiff(a::AbstractArray, ; dims,)
#     diff(a; dims)
# end

# const _C = ipv(stack([range(-1.5, 1.5, 4) .^ p for p = 0:3]))[2, :]
# select = 1:ndims(a) .== dims
# n = size(a, dims)
# T = eltype(a)
# zsz = size(a) .* (1 - select) + select |> Tuple
# z = zeros(T, zsz)
# z = typeof(a)(z)
# else
#     m = parentmodule(T)
#     _zeros = isdefined(m, :zeros) ? m.zeros : zeros
#     z = _zeros(zsz)
# end

# C = T.(_C)
# if n > 5
#     L = selectdim(a, dims, 2:2) - selectdim(a, dims, 1:1)
#     M = sum(C .* selectdim.((a,), dims, range.(1:4, n - (3:-1:0))))
#     R = selectdim(a, dims, n:n) - selectdim(a, dims, n-1:n-1)
#     if shifts[dims] == -1
#         return cat(z, L, M, R, dims=dims)
#     elseif shifts[dims] == 1
#         return cat(L, M, R, z, dims=dims)
#     end
# end


# function fftsdiff(a, diffpadvals=zeros(Int, ndims(a), 2); dims)
#     T = eltype(a)
#     select = 1:ndims(a) .== dims
#     n = size(a, dims)

#     # ω = repeat(2π / n * (0:n-1), (size(a) .* (1 - select) + select)...)
#     # @memoize
#     ω = 2π / n * (getindex.(CartesianIndices(a), dims) - 1)
#     ω = typeof(a)(ω)
#     ω = (ω + π) .% (2π) - π
#     D = im * ω
#     E = cis.(ω / 2)
#     A = fft(a)
#     Da = real(ifft(E .* D .* A))
#     Da = selectdim(Da, dims, 1:n-1)

#     l, r = eachcol(diffpadvals)
#     shifts = r - l
#     zsz = size(a) .* (1 - select) + select |> Tuple
#     z = zeros(T, zsz)
#     z = typeof(a)(z)

#     if shifts[dims] == -1
#         return cat(z, Da, dims=dims)
#     elseif shifts[dims] == 1
#         return cat(Da, z, dims=dims)
#         # elseif l[dims] == 0
#         #     return diff(a; dims)
#         # elseif l[dims] == 1
#         #     return pad(diff(a; dims), 0, select)
#     end
# end

# function (m::Del)(a::AbstractArray{<:pumber}, p=*)
#     @unpack Δ, diffpadvals = m
#     n = length(Δ)
#     if n == 1
#         return pdiff(a) / Δ[1]
#     end

#     I = [ax[begin:end-1] for ax = axes(a)[1:n]]
#     if p == *
#         return [pdiff(a, dims=i) for i = 1:n] ./ Δ
#     elseif p == cross
#         dx, dy = Δ
#     end
# end


# function (m::Laplacian)(a)
#     sum([lap(a, dims=i) * Δ for (i, Δ) = zip(Δ)])
# end
# function (m::Laplacian)(v::VF)
#     m.(a)
# end



# else
#     # b = T(zeros(size(a)))
#     b = similar(a)
#     # b = autodiff ? Buffer(a) : similar(a)
#     i = [s ? (2:n) : (:) for s = select]
#     b[i...] = diff(a; dims)
#     i = [s ? (1:1) : (:) for s = select]
#     b[i...] = z
#     # autodiff && return copy(b)
#     return b
# end
#     # b = a - circshift(a, select)
#     # b = cat(z, selectdim(b, dims, 2:n), dims=dims)
#     b = autodiff ? Buffer(a) : similar(a)
# end
# # autodiff && return copy(b)
# return b
#     # b = Buffer(a)
#     b[[i == 0 ? (:) : 2:(size(a, dims)) for i = select]...] = diff(a; dims)
#     # return copy(b)
#     # cat(selectdim(a, dims, 1:1), diff(a; dims), dims=dims)
#     return b
# end
# return cat(diff(a; dims), z, dims=dims)

#     # b = T(zeros(size(a)))
#     b = similar(a)
#     # b = autodiff ? Buffer(a) : similar(a)
#     i = [s ? (1:n-1) : (:) for s = select]
#     b[i...] = diff(a; dims)
#     i = [s ? (n:n) : (:) for s = select]
#     b[i...] = z
#     # autodiff && return copy(b)
#     return b
# end
#     b = circshift(a, -select) - a
#     b = cat(selectdim(b, dims, 1:n-1), z, dims=dims)
#     b = autodiff ? Buffer(a) : similar(a)
# end
# # autodiff && return copy(b)
#     b[[i == 0 ? (:) : 1:(size(a, dims)-1) for i = select]...] = diff(a; dims)
#     return b
#     # return copy(b)
# end

# a_ = Buffer(a)
# if v == 1
#     # return a - circshift(a, select)
#     i = [i == dims ? ax[2:end] : ax for (i, ax) = epumerate(axes(a))]
#     i_ = [i == dims ? (1:1) : ax for (i, ax) = epumerate(axes(a))]
# elseif v == -1
#     # return circshift(a, -select) - a
#     i = [i == dims ? ax[1:end-1] : ax for (i, ax) = epumerate(axes(a))]
#     i_ = [i == dims ? (ax[end]:ax[end]) : ax for (i, ax) = epumerate(axes(a))]
# elseif left(a)[dims] == 1
#     return diff(a; dims)
# elseif left(a)[dims] == 0
#     return pad(diff(a; dims), 0, select)
# end

# a_[i...] = diff(a; dims)
# a_[i_...] = fill(0, length.(i_)...)
# # fill![i_...] .= 0
# copy(a_)
