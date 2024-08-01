
struct StaggeredDel
    Δ::AbstractArray
    autodiff::Bool
    function StaggeredDel(Δ::AbstractArray; autodiff=true)#; tpad=zeros(Int, length(Δ, 2)), cd::Bool=false)
        new(Δ, autodiff)
    end
end
# @functor StaggeredDel
struct CenteredDel
    Δ::AbstractArray
end
struct Laplacian
    Δ::AbstractArray
end
Del = Union{StaggeredDel,CenteredDel}
function lap(a::AbstractArray, ; dims=1)
    select = 1:ndims(a) .== dims
    circshift(a, -select) - 2a + circshift(a, select)
end
function cdiff(a::AbstractArray, ; dims,)
    diff(a; dims)
end

function sdiff(a, ; dims, autodiff=true)
    select = 1:ndims(a) .== dims
    shifts = right(a) - left(a)
    a = Array(a)
    T = typeof(a)
    v = shifts[dims]
    n = size(a, dims)
    zsz = collect(size(a))
    ignore_derivatives() do
        zsz[dims] = 1
        zsz = tuple(zsz...)
    end
    z = T(zeros(zsz))

    if v == 1

        if autodiff
            return cat(z, diff(a, ; dims), dims=dims)

        else
            b = T(zeros(size(a)))
            i = [s ? (2:n) : (:) for s = select]
            b[i...] = diff(a; dims)
            return b
        end
        #     # b = a - circshift(a, select)
        #     # b = cat(z, selectdim(b, dims, 2:n), dims=dims)
        #     b = autodiff ? Buffer(a) : similar(a)
        #     i = [s ? (1:1) : (:) for s = select]
        #     b[i...] = z
        # end
        # # autodiff && return copy(b)
        # return b
        #     # b = Buffer(a)
        #     b = similar(a)
        #     b[[i == 0 ? (:) : 2:(size(a, dims)) for i = select]...] = diff(a; dims)
        #     # return copy(b)
        #     # cat(selectdim(a, dims, 1:1), diff(a; dims), dims=dims)
        #     return b
        # end
    elseif v == -1
        if autodiff
            return cat(diff(a; dims), z, dims=dims)
        else
            b = T(zeros(size(a)))
            i = [s ? (1:n-1) : (:) for s = select]
            b[i...] = diff(a; dims)
            return b
        end
        #     b = circshift(a, -select) - a
        #     b = cat(selectdim(b, dims, 1:n-1), z, dims=dims)
        #     b = autodiff ? Buffer(a) : similar(a)
        #     i = [s ? (n:n) : (:) for s = select]
        #     b[i...] = z
        # end
        # # autodiff && return copy(b)
        #     b = similar(a)
        #     b[[i == 0 ? (:) : 1:(size(a, dims)-1) for i = select]...] = diff(a; dims)
        #     return b
        #     # return copy(b)
        # end
    elseif left(a)[dims] == 1
        return diff(a; dims)
    elseif left(a)[dims] == 0
        return pad(diff(a; dims), 0, select)
    end

    # a_ = Buffer(a)
    # if v == 1
    #     # return a - circshift(a, select)
    #     i = [i == dims ? ax[2:end] : ax for (i, ax) = enumerate(axes(a))]
    #     i_ = [i == dims ? (1:1) : ax for (i, ax) = enumerate(axes(a))]
    # elseif v == -1
    #     # return circshift(a, -select) - a
    #     i = [i == dims ? ax[1:end-1] : ax for (i, ax) = enumerate(axes(a))]
    #     i_ = [i == dims ? (ax[end]:ax[end]) : ax for (i, ax) = enumerate(axes(a))]
    # elseif left(a)[dims] == 1
    #     return diff(a; dims)
    # elseif left(a)[dims] == 0
    #     return pad(diff(a; dims), 0, select)
    # end

    # a_[i...] = diff(a; dims)
    # a_[i_...] = fill(0, length.(i_)...)
    # # fill![i_...] .= 0
    # copy(a_)
end

function (m::Del)(a::AbstractArray{<:Number}, p=*)
    @unpack Δ, autodiff = m
    n = length(Δ)
    if n == 1
        return pdiff(a) / Δ[1]
    end

    I = [ax[begin:end-1] for ax = axes(a)[1:n]]
    if p == *
        return [pdiff(a, dims=i) for i = 1:n] ./ Δ
    elseif p == cross
        dx, dy = Δ
    end
end

function (m::StaggeredDel)(a, p=*)
    @unpack Δ, autodiff = m
    a = a |> values
    n = length(Δ)
    # I = [ax[begin:end-1] for ax = axes(first(a))]
    if p == dot
        return sum([pdiff(a[i], dims=i) for i = 1:n] ./ Δ)
    elseif p == cross
        if n == 2
            dx, dy = Δ
            if length(a) == 1
                u, = a
                return [sdiff(u; autodiff, dims=2) / dy, -sdiff(u; autodiff, dims=1) / dx]
            else
                u, v = a
                return [sdiff(v; autodiff, dims=1) / dx - sdiff(u; autodiff, dims=2) / dy]
            end
        elseif n == 3
            dx, dy, dz = Δ
            u, v, w = a
            uy = sdiff(u; autodiff, dims=2) / dy
            uz = sdiff(u; autodiff, dims=3) / dz
            vx = sdiff(v; autodiff, dims=1) / dx
            vz = sdiff(v; autodiff, dims=3) / dz
            wx = sdiff(w; autodiff, dims=1) / dx
            wy = sdiff(w; autodiff, dims=2) / dy
            return [wy - vz, uz - wx, vx - uy]
        end
    end
end

function (m::Laplacian)(a)
    sum([lap(a, dims=i) * Δ for (i, Δ) = zip(Δ)])
end
function (m::Laplacian)(v::VF)
    m.(a)
end

function LinearAlgebra.dot(m::Del, a)
    m(a, dot)
end

function LinearAlgebra.cross(m::Del, a)
    m(a, cross)
end

