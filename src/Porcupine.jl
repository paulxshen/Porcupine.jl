module Porcupine
include("main.jl")
export Map, List, Collection, Container, Text
export cdiff, grad, hess, Del # Laplacian#, Op, Gauss
export dict, namedtuple
export recursive_getindex, approx_getindex
export getindexf, setindexf!, crop
export trim, fmap, kmap, leaves, flatten, sortkeys
export °, gaussian, dropitr, adddims
export int
export upsample, downsample, downsample_by_range, _downvec, v2i, indexof, i2v
export symmetric
export ⊙, ⊘
export @ignore_derivatives_vars, @convert
export invperm, permutedims, adddims
# export round, ceil, floor
# keys, values, first,
end # module FDMTK
