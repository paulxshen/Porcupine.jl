function symmetric(v)
    n = length(v)
    N = floor(2n)
    [v[cumsum(1:i)+j-N] for i = 1:N, j = 1:N]
end