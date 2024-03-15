module Porcupine
using UnPack, LinearAlgebra, ArrayPadding, ChainRulesCore
# using Zygote: Buffer
# include("ops.jl")
include("del.jl")
export Del, StaggeredDel, CenteredDel, Laplacian#, Op, Gauss
end # module FDMTK
