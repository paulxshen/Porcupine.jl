module Porcupine
include("main.jl")
export Del, StaggeredDel, CenteredDel, Laplacian#, Op, Gauss
export dict, keys, values, _getindex, Numeric, Dictlike, List, Collection
export °, gaussian
export whole, apply, apply_func, approx_getindex, flatten
end # module FDMTK
