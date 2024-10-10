
downsample(f, a, S) = [
    begin
        I = Tuple(I)
        start = 1 + S * (I - 1)
        f(a[range.(start, start + S - 1)...])
    end for I = CartesianIndices(size(a) .÷ S)
]
downsample(a, ratio) = downsample(mean, a, ratio)

function upsample(a, S)
    A = zeros(complex(eltype(a)), S * size(a))
    A[Base.OneTo.(size(a))...] .= fft(a)
    ifft(A)
end