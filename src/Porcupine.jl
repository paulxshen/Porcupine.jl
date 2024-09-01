module Porcupine
include("main.jl")
export Del, StaggeredDel, CenteredDel, Laplacian#, Op, Gauss
export dict, namedtuple, group, recursive_getindex, approx_getindex, unroll, Numeric, Dictlike, List, Collection
export °, gaussian
export whole, apply, fmap, approx_getindex, leaves, flatten, hasnan, interp
end # module FDMTK
