module Porcupine
include("main.jl")
export Map, List, Collection, ArrayLike, Str
export dict, namedtuple, regex
export getindexr, approx_getindex
export getindexf, getindexs, place!, crop, indexof
export trim, rmap, fmap, kvmap, kmap, vmap, leaves, flatten, sortkeys
export °, gaussian, dropitr, adddims
export int, signedfloor, signedceil
export upsample, downsample, downsample_by_range, _downvec
export divΔ, centroids, centroidvals
export symmetric
export ⊙, ⊘, Del, cdiff
export @nograd, @convert, AD, unstack
# export invperm, permutedims, adddims
export cpu, gpu
export gc, timepassed, AUTODIFF
export constructor
export todxyz, todvoa
export imnormal, improj, getbbox, resize
export togreek, fromgreek
export round1, round2, round3, round4, round5, round6
export disp, BREAK, DBREAK, @getr
export _values, rcopy!
# export keys, _values, pairs, first
end # module FDMTK
