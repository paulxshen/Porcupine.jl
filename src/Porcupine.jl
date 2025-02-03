module Porcupine
include("main.jl")
export Map, List, Collection, Container, Text
export dict, namedtuple, regex
export recursive_getindex, approx_getindex
export getindexf, getindexs, setindexf!, crop
export trim, fmap, kmap, leaves, flatten, sortkeys
export °, gaussian, dropitr, adddims
export int
export upsample, downsample, downsample_by_range, _downvec, v2i, indexof
export symmetric
export ⊙, ⊘
export @nograd, @convert
export invperm, permutedims, adddims
export cpu, gpu
export gc, timepassed, AUTODIFF
export constructor
export packxyz, unpackxyz
export imnormal, getbbox
export togreek, fromgreek
# export round, ceil, floor
# export keys, values, pairs, first
end # module FDMTK
