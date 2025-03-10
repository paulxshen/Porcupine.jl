module Porcupine
include("main.jl")
export Map, List, Collection, Container, Text
export dict, namedtuple, regex
export getindexr, approx_getindex
export getindexf, getindexs, place!, crop, indexof
export trim, fmap, kvmap, vmap, leaves, flatten, sortkeys
export °, gaussian, dropitr, adddims
export int, signedfloor, signedceil
export upsample, downsample, downsample_by_range, _downvec
export divΔ, centroids, centroidvals
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
export disp, BREAK, DBREAK
# export keys, values, pairs, first
end # module FDMTK
