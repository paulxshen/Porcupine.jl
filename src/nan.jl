hasnan(x::Number) = isnan(x)
hasnan(a) = any(hasnan, a)
hasnan(d::Dictlike) = hasnan(leaves(d))