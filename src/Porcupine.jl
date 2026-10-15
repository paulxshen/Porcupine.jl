module Porcupine
include("main.jl")
export Map, List, Collection, ArrayLike, Str
export dict, namedtuple, regex
export getindexr, approx_getindex
export getindexf, getindexs, place!, crop, indexof
export rmap, kvmap, kmap, vmap, leaves, flatten, sortkeys
export °, gaussian
export int, signedfloor, signedceil
export divΔ, centroids, centroidvals
export symmetric
export @nograd, AD, unstack
# export invperm, permutedims, adddims
export cpu, gpu
export timepassed
export constructor
export imnormal, improj, getbbox, resize
export togreek, fromgreek
export 𝒻, BREAK, DBREAK
export _values, rcopy!, call
# export keys, _values, pairs, first
end # module FDMTK
