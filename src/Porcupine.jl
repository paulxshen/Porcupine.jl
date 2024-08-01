module Porcupine
include("main.jl")
export Del, StaggeredDel, CenteredDel, Laplacian#, Op, Gauss
export dict, _getindex, Numeric, Dictlike, List, Collection
export °, gaussian
export whole, apply, fmap, approx_getindex, leaves, hasnan, interp
end # module FDMTK
