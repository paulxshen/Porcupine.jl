module Porcupine
using UnPack, LinearAlgebra, ArrayPadding
# using Zygote: Buffer
include("del.jl")
include("ops.jl")
export Del, StaggeredDel, CenteredDel, Laplacian#, Op, Gauss
end # module FDMTK
