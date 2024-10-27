module Porcupine
include("main.jl")
export Map, List, Collection, Container, Text
export Del # Laplacian#, Op, Gauss
export dict, namedtuple
export recursive_getindex, approx_getindex
export getindexf, setindexf!, crop
export trim, fmap, kmap, leaves, flatten
export °, gaussian, dropitr, adddims
export int
export upsample, downsample, v2i, indexof, i2v
export symmetric
export ⊙, ⊘
# export round, ceil, floor
# keys, values, first,
end # module FDMTK
