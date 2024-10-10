hasnan(x::Number) = isnan(x)
hasnan(a) = any(hasnan, a)
hasnan(d::Map) = hasnan(leaves(d))