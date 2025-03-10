round(x) = Base.round.(Int, x)
round(T, x) = Base.round.(T, x)

function int(x::Real, tol=0.01)
    i = round(Int, x)
    d = abs(x - i)
    @assert d < tol "$x is not an integer within tolerance $tol"
    i
end
int(x::Float16) = int(x, 0.1)
int(x::Float32) = int(x, 0.01)

int(x) = fmap(int, x)

signedfloor(x) = x > 0 ? floor(Int, x) : ceil(Int, x)
signedceil(x) = x > 0 ? ceil(Int, x) : floor(Int, x)

