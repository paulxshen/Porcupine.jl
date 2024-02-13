module Porcupine
using UnPack, LinearAlgebra, Zygote, ArrayPadding
using Zygote: bufferfrom
include("del.jl")
export Del, StaggeredDel, CenteredDel#, Lap, Op, Gauss
end # module FDMTK
