
function downsample(f, a, ratio)
    ratio == 1 && return a
    [
        begin
            I = Tuple(I)
            start = 1 + ratio * (I - 1)
            f(a[range.(start, start + ratio - 1)...])
        end for I = CartesianIndices(size(a) .÷ ratio)
    ]
end
downsample(a, ratio) = downsample(mean, a, ratio)

function upsample(a, ratio)
    A = zeros(complex(eltype(a)), ratio * size(a))
    A[Base.OneTo.(size(a))...] .= fft(a)
    ifft(A)
end